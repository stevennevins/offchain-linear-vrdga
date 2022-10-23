// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {toWadUnsafe, wadExp, wadLn, unsafeWadMul, unsafeWadDiv, wadMul} from "solmate/utils/SignedWadMath.sol";
import {toDaysWadUnsafe} from "../utils/SignedWadMath.sol";
import {LinearVRGDAInfo as LVRGDAInfo} from "../interfaces/ILinearVRGDA.sol";

library LibLinearVRGDA {
    function getVRGDAPrice(LVRGDAInfo calldata self, uint256 numSold)
        public
        view
        returns (uint256)
    {
        unchecked {
            // prettier-ignore
            return uint256(wadMul(self.targetPrice, wadExp(unsafeWadMul(computeDecayConstant(self.priceDecayPercent),
                // Theoretically calling toWadUnsafe with sold can silently overflow but under
                // any reasonable circumstance it will never be large enough. We use sold + 1 as
                // the VRGDA formula's n param represents the nth token and sold is the n-1th token.
                toDaysWadUnsafe(block.timestamp - self.startTime) - getTargetSaleTime(toWadUnsafe(numSold + 1), self.perTimeUnit)
            ))));
        }
    }

    function toHash(LVRGDAInfo calldata self) public pure returns (bytes32) {
        return keccak256(abi.encode(self));
    }

    /// @dev Given a number of tokens sold, return the target time that number of tokens should be sold by.
    /// @param sold A number of tokens sold, scaled by 1e18, to get the corresponding target sale time for.
    /// @param perTimeUnit The number of tokens to target selling in 1 full unit of time, scaled by 1e18.
    /// @return The target time the tokens should be sold by, scaled by 1e18, where the time is
    /// relative, such that 0 means the tokens should be sold immediately when the VRGDA begins.
    function getTargetSaleTime(int256 sold, int256 perTimeUnit)
        public
        pure
        returns (int256)
    {
        return unsafeWadDiv(sold, perTimeUnit);
    }

    /// @dev Calculate constant that allows us to rewrite a pow() as an exp().
    /// @param priceDecayPercent The percent price decays per unit of time with no sales, scaled by 1e18.
    /// @return The computed constant represented as an 18 decimal fixed point number.
    function computeDecayConstant(int256 priceDecayPercent)
        public
        pure
        returns (int256)
    {
        return wadLn(1e18 - priceDecayPercent);
    }
}
