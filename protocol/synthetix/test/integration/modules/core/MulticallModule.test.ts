/* eslint-disable @typescript-eslint/ban-ts-comment */

import assert from 'assert/strict';
import { bootstrap } from '../../bootstrap';
import { ethers } from 'ethers';
import assertRevert from '@synthetixio/core-utils/utils/assertions/assert-revert';
import assertEvent from '@synthetixio/core-utils/utils/assertions/assert-event';
import hre from 'hardhat';
import Permissions from '../../mixins/AccountRBACMixin.permissions';

describe.only('MulticallModule', function () {
  const { systems, signers } = bootstrap();

  let owner: ethers.Signer, user1: ethers.Signer;

  before('identify signers', async () => {
    [owner, user1] = signers();
  });

  describe('multicall()', () => {
    it('passes through errors', async () => {
      await assertRevert(
        systems()
          .Core.connect(user1)
          .multicall([
            systems().Core.interface.encodeFunctionData('createAccount(uint128)', [
              '170141183460469231731687303715884105727',
            ]),
          ]),
        `InvalidAccountId("170141183460469231731687303715884105727")`,
        systems().Core
      );
    });

    describe('on success', async () => {
      before('call', async () => {
        await systems()
          .Core.connect(user1)
          .multicall([
            systems().Core.interface.encodeFunctionData('createAccount(uint128)', [1234421]),
            systems().Core.interface.encodeFunctionData('createAccount(uint128)', [1234422]),
            systems().Core.interface.encodeFunctionData('createAccount(uint128)', [1234423]),
            systems().Core.interface.encodeFunctionData('createAccount(uint128)', [1234424]),
          ]);
      });

      it('creates all the accounts', async () => {
        assert.equal(await systems().Account.ownerOf(1234421), await user1.getAddress());
        assert.equal(await systems().Account.ownerOf(1234422), await user1.getAddress());
        assert.equal(await systems().Account.ownerOf(1234423), await user1.getAddress());
        assert.equal(await systems().Account.ownerOf(1234424), await user1.getAddress());
      });
    });
  });

  describe('multicallThrough()', () => {
    it('passes through errors', async () => {
      await assertRevert(
        systems()
          .Multicall.connect(user1)
          //@ts-ignore tests is skipped, fixe type when enabled
          .multicallThrough(
            [systems().Core.address],
            [
              systems().Core.interface.encodeFunctionData('createAccount(uint128)', [
                '170141183460469231731687303715884105727',
              ]),
            ],
            [0]
          ),
        `InvalidAccountId("170141183460469231731687303715884105727")`,
        systems().Core
      );
    });

    describe('on success', async () => {
      before('call', async () => {
        await systems()
          .Multicall.connect(user1)
          //@ts-ignore tests is skipped, fixe type when enabled
          .multicallThrough(
            [systems().Core.address, systems().Core.address, systems().OracleManager.address, systems().Core.address, systems().Account.address],
            [
              systems().Core.interface.encodeFunctionData('createAccount(uint128)', [1234434]),
              systems().Core.interface.encodeFunctionData('createAccount(uint128)', [1234435]),
              systems().OracleManager.interface.encodeFunctionData('registerNode', [
                8,
                ethers.utils.defaultAbiCoder.encode(['uint256'], [429]),
                [],
              ]),
              systems().Core.interface.encodeFunctionData('grantPermission', [1234434, Permissions.ADMIN, await owner.getAddress()]),
              systems().Account.interface.encodeFunctionData('transferFrom', [await user1.getAddress(), await owner.getAddress(), 1234435]),
            ],
            [0, 0, 0, 0, 0]
          );
      });

      it('calls through on both contracts', async () => {
        const nodeId = systems().OracleManager.getNodeId(
          8,
          ethers.utils.defaultAbiCoder.encode(['uint256'], [429]),
          []
        );

        assert.equal(await systems().Account.ownerOf(1234434), await user1.getAddress());
        assert.equal(await systems().Account.ownerOf(1234435), await owner.getAddress());
        assert.equal(await systems().Core.hasPermission(1234434, Permissions.ADMIN, await owner.getAddress()), true);
        assert.equal((await systems().OracleManager.getNode(nodeId)).nodeType, 8);
      });
    });

    describe('verify messageSender', async () => {
      let receiverContract: ethers.Contract;
      let tx: ethers.providers.TransactionResponse;
      before('deploy multicall receiver', async () => {
        const factory = await hre.ethers.getContractFactory('MulticallReceiverMock');
        const MulticallReceiver = await factory.deploy();
        receiverContract = await MulticallReceiver.deployed();

        tx = await systems()
          .Multicall.connect(user1)
          .multicallThrough(
            [receiverContract.address],
            [receiverContract.interface.encodeFunctionData('testMessageSender')],
            [0]
          );
      });

      it('emits event confirming msg sender is correct', async () => {
        await assertEvent(
          tx,
          `MessageSenderTested("${await user1.getAddress()}")`,
          receiverContract
        );
      });

      it('should have reset messageSender after multicall', async () => {
        assert.equal(await systems().Multicall.getMessageSender(), ethers.constants.AddressZero);
      });
    });
  });
});
