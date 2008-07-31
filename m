From: Eddie Kohler <kohler@cs.ucla.edu>
Date: Thu, 31 Jul 2008 16:14:31 +0000
Subject: Re: [PATCH] DCCP: Fix to handle invalid packets in REQUEST state
Message-Id: <4891E4E7.1050003@cs.ucla.edu>
List-Id: <dccp.vger.kernel.org>
References: <488FF324.6050706@cn.fujitsu.com>
In-Reply-To: <488FF324.6050706@cn.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Wei,

Wei Yongjun wrote:
>>> 1. If invalid Dccp-DataAck packets is received in the REQUEST state, the  
>>> socket just send back Dccp-Rest with invalid packet error, but the  
>>> socket is not reset, Dccp-Request will be continue retranmitted. The  
>>> procedure is like this:
>>>
>>> Endpoint A                   Endpint B
>>>         <-----------------  Request
>>> DataAck  ----------------->          <-----------------  Reset (invalid 
>>> packet)
>>>         <-----------------  Request (retranmit)
>>>
>>>     
>> This is not a bug but as far as I know correct behaviour. The DataAck
>> could be from a previous incarnation of the same connection, or it could
>> be an erratic packet. RFC 4340, 5.6 says about this error code
>>  "Packet Error"
>>    A valid packet arrived with unexpected type.  For example, a
>>    DCCP-Data packet with valid header checksum and sequence numbers
>>    arrived at a connection in the REQUEST state. 
>>
>> The client keeps on retransmitting the Request since this is a
>> requirement from 8.1.3; the number of retransmissions is limited
>> by net.dccp.default.request_retries.
>>
>> Hence this case is in principle correct.
> 
> This case is correct. 7.5.6 has an final example demonstrates recovery
> from a half-open connection. The difference is that Dccp-Sync is
> received in REQUEST state.
> This make me confusion. When to sent reset not close the connection,
> when to sent reset and need close the connection?

A sequence-valid Reset would close the connection.  The easiest way to see
this based on the specification (as opposed to the Linux code) is to follow
the pseudocode in Section 8.5 of RFC4340.  This pseudocode also makes clear
that on some error conditions that generate a Reset, the socket should not be
closed.

Eddie
