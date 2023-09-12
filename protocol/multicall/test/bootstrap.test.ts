import { coreBootstrap } from '@synthetixio/router/dist/utils/tests';
import { ethers } from 'ethers';
import hre from 'hardhat';
import { MulticallModule } from './generated/typechain';
import { wei } from '@synthetixio/wei';

const abi = ethers.utils.defaultAbiCoder;

interface Contracts {
    MulticallModule: MulticallModule;
}
const r = coreBootstrap<Contracts>();

const restoreSnapshot = r.createSnapshot();

export function bootstrap() {
  before(restoreSnapshot);
  return r;
}

describe('MulticallModule', function () {
    const r = bootstrap();

    it('Test deployment', async () => {
    });
});