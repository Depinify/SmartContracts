//SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@chainlink/contracts/src/v0.8/ChainlinkClient.sol";
import "@chainlink/contracts/src/v0.8/ConfirmedOwner.sol";
import "../Config.sol";

/**
 * Mesh
 */

contract MeshControl is ChainlinkClient, ConfirmedOwner, Config {
  using Chainlink for Chainlink.Request;

  // Result data map: requestId => result
  mapping (bytes32 => string) public _result;

  uint256 private fee;
  bytes32 public currentKey;
  string public currentData;

  struct Site {
    bytes32 jobId;
    address oracle;
    string host;
  }
  // site configuration
  mapping (string => Site) public _sites;

  /**
   * @notice Initialize the link token and target oracle
     * @dev The oracle address must be an Operator contract for multiword response
     *
     */
  constructor(uint256 _fee, address _link) ConfirmedOwner(msg.sender) {
    setChainlinkToken(_link);
    // setChainlinkOracle(_oracle);
    fee = _fee; // 0,1 * 10**18 (Varies by network and job)
  }

  // Register site configuration
  function setSites(string memory _name, string memory _jobId, address _oracle, string memory host) public{
    require(msg.sender == owner());
    require(bytes(_name).length > 0);
    require(bytes(_jobId).length > 0);
    require(_oracle != address(0));
    require(bytes(host).length > 0);
    _sites[_name] = Site(stringToBytes32(_jobId), _oracle, host);
  }

  // Service circuit breaker
  function fuseRule(
    string memory _siteName,
    string memory _requestData,
    bytes32 _requestUID
  ) public verificationSite(_siteName){
    _requestData = (bytes(_requestData).length > 0 ? _requestData : "e30=");
    string memory url = string(abi.encodePacked(_sites[_siteName].host, "/api/v1/govern/fuse/rule"));
    request(
      "POST",
      url,
      "W10=",
      _requestData,
      _siteName,
      _requestUID
    );
  }

  // Verify site metadata
  modifier verificationSite(
    string memory _siteName
  ) {
    require(_sites[_siteName].oracle != address(0), "This site does not exist");
    _;
  }

  // Service throttling
  function rateLimitRule(
    string memory _siteName,
    string memory _requestData,
    bytes32 _requestUID
  ) public verificationSite(_siteName){
    _requestData = (bytes(_requestData).length > 0 ? _requestData : "e30=");
    string memory url = string(abi.encodePacked(_sites[_siteName].host, "/api/v1/govern/rate/rule"));
    request(
      "POST",
      url,
      "W10=",
      _requestData,
      _siteName,
      _requestUID
    );
  }

  // Query data
  function getResultData(
    bytes32 _requestUID
  ) public view returns (string memory){
    return _result[_requestUID];
  }

  /**
   * @notice Request variable string from the oracle
     */
  function request(
    string memory _method,
    string memory _url,
    string memory _headers,
    string memory _requestData,
    string memory _siteName,
    bytes32 _requestUID
  ) internal verificationSite(_siteName){
    _method = (bytes(_method).length > 0 ? _method : "GET");
    require(bytes(_url).length > 0);
    _headers = (bytes(_headers).length > 0 ? _headers : "W10=");
    _requestData = (bytes(_requestData).length > 0 ? _requestData : "e30=");

    Chainlink.Request memory req = buildChainlinkRequest(
      _sites[_siteName].jobId,
      address(this),
      this.fulfill.selector
    );
    req.add("url", _url);
    req.add("method", _method);
    req.add("headers", _headers);
    req.add("requestData", _requestData);
    req.addBytes("requestUID", abi.encodePacked(_requestUID));
    sendChainlinkRequestTo(_sites[_siteName].oracle, req, fee);
  }

  event RequestFulfilled(bytes32 indexed _requestUID, string data);

  /**
   * @notice Fulfillment function for variable string
     * @dev This is called by the oracle. recordChainlinkFulfillment must be used.
     */
  function fulfill(
    bytes32 _requestId,
    bytes32 _requestUID,
    string memory _stringData
  ) public recordChainlinkFulfillment(_requestId) {
    emit RequestFulfilled(_requestUID, _stringData);
    _result[_requestUID] = _stringData;
    currentKey = _requestUID;
    currentData = _stringData;
  }

  function stringToBytes32(
    string memory source
  ) private pure returns (bytes32 result) {
    bytes memory tempEmptyStringTest = bytes(source);
    if (tempEmptyStringTest.length == 0) {
      return 0x0;
    }

    assembly {
    // solhint-disable-line no-inline-assembly
      result := mload(add(source, 32))
    }
  }

}