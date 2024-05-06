// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

// Deploy on Amoy

import {FunctionsClient} from "@chainlink/contracts/src/v0.8/functions/dev/v1_0_0/FunctionsClient.sol";
import {ConfirmedOwner} from "@chainlink/contracts/src/v0.8/shared/access/ConfirmedOwner.sol";
import {FunctionsRequest} from "@chainlink/contracts/src/v0.8/functions/dev/v1_0_0/libraries/FunctionsRequest.sol";

/**
 * Request testnet LINK and ETH here: https://faucets.chain.link/
 * Find information on LINK Token Contracts and get the latest ETH and LINK faucets here: https://docs.chain.link/resources/link-token-contracts/
 */

/**
 * @title GettingStartedFunctionsConsumer
 * @notice This is an example contract to show how to make HTTP requests using Chainlink
 * @dev This contract uses hardcoded values and should not be used in production.
 */
contract fetchData is FunctionsClient, ConfirmedOwner {
    using FunctionsRequest for FunctionsRequest.Request;

    // State variables to store the last request ID, response, and error
    bytes32 public s_lastRequestId_a;
    bytes32 public s_lastRequestId_b;
    bytes public s_lastResponse;
    bytes public s_lastError;
    uint64 subscriptionId;

    // Custom error type
    error UnexpectedRequestID(bytes32 requestId);

    // Event to log responses
    event Response(
        bytes32 indexed requestId,
        string character,
        bytes response,
        bytes err
    );

    // Hardcoded for amoy
    // Supported networks https://docs.chain.link/chainlink-functions/supported-networks
    address router = 0xC22a79eBA640940ABB6dF0f7982cc119578E11De;
    bytes32 donID =
        0x66756e2d706f6c79676f6e2d616d6f792d310000000000000000000000000000;

    //Callback gas limit
    uint32 gasLimit = 300000;

    // JavaScript source code
    // Fetch character name from the Star Wars API.
    // Documentation: https://swapi.dev/documentation#people
    string source_a =
        "const apiResponse = await Functions.makeHttpRequest({"
        "url: `https://microtest-flame.vercel.app/`"
        "});"
        "if (apiResponse.error) {"
        "throw Error('Request failed');"
        "}"
        "const { data } = apiResponse;"
        // "const consumed = Functions.encodeUint256(data.powerConsumed);"
        "const generated = Functions.encodeUint256(data.powerGenerated);"
        // "const tokenid = Functions.encodeUint256(data.tokenId);"
        // "const address = Functions.encodeString(data.userAccount)"
        "return generated";
    string source_b =
        "const apiResponse = await Functions.makeHttpRequest({"
        "url: `https://microtest-flame.vercel.app/`"
        "});"
        "if (apiResponse.error) {"
        "throw Error('Request failed');"
        "}"
        "const { data } = apiResponse;"
        "const consumed = Functions.encodeUint256(data.powerConsumed);"
        // "const generated = Functions.encodeUint256(data.powerGenerated);"
        // "const tokenid = Functions.encodeUint256(data.tokenId);"
        // "const address = Functions.encodeString(data.userAccount)"
        "return consumed";

    // State variable to store the returned character information
    string public responseData;

    /**
     * @notice Initializes the contract with the Chainlink router address and sets the contract owner
     */
    constructor() FunctionsClient(router) ConfirmedOwner(msg.sender) {
        
    }



     function sendRequests() external onlyOwner {

    sendRequest_a();
    sendRequest_b();
     }


    function sendRequest_a(
        // uint64 subscriptionId
        // string[] calldata args
    ) internal onlyOwner returns (bytes32 requestId) {
        FunctionsRequest.Request memory req;
        req.initializeRequestForInlineJavaScript(source_a); // Initialize the request with JS code
        // if (args.length > 0) req.setArgs(args); // Set the arguments for the request

        // Send the request and store the request ID
        s_lastRequestId_a = _sendRequest(
            req.encodeCBOR(),
            subscriptionId,
            gasLimit,
            donID
        );

        return s_lastRequestId_a;
    }
    function sendRequest_b(
        // uint64 subscriptionId
        // string[] calldata args
    ) internal onlyOwner returns (bytes32 requestId) {
        FunctionsRequest.Request memory req;
        req.initializeRequestForInlineJavaScript(source_b); // Initialize the request with JS code
        // if (args.length > 0) req.setArgs(args); // Set the arguments for the request

        // Send the request and store the request ID
        s_lastRequestId_b = _sendRequest(
            req.encodeCBOR(),
            subscriptionId,
            gasLimit,
            donID
        );

        return s_lastRequestId_b;
    }

function getGeneratedValue() public view returns (uint256) {
    return re_generated;
}
function getConsumedValue() public view returns (uint256) {
    return re_consumed;
}


    //  string public re_address;
    //  uint256 public re_tokenid;
     uint256 public re_consumed;
     uint256 public re_generated;

    function fulfillRequest(
        bytes32 requestId,
        bytes memory response,
        bytes memory err
    ) internal override {
        if (s_lastRequestId_a == requestId) {
            // revert UnexpectedRequestID(requestId); // Check if request IDs match
        
        // Update the contract's state variables with the response and any errors
        s_lastResponse = response;
        responseData = string(response);
        s_lastError = err;

        //decode data
        // (string memory r_Address, uint256 r_tokenID, uint256 r_consumed, uint256 r_generated) = abi.decode(response, (string,uint256,uint256,uint256));

        // re_address = r_Address;
        // re_tokenid = r_tokenID;
        // re_consumed = r_consumed;
        re_generated = abi.decode(response, (uint256));

        // Emit an event to log the response
        emit Response(requestId, responseData, s_lastResponse, s_lastError);
        }else if (s_lastRequestId_b == requestId) {
                // Update the contract's state variables with the response and any errors
        s_lastResponse = response;
        responseData = string(response);
        s_lastError = err;

        //decode data
      re_consumed = abi.decode(response, (uint256));
        }else{
            revert UnexpectedRequestID(requestId); // Check if request IDs match
        }
    }
}