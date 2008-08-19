From: Wei Yongjun <yjwei@cn.fujitsu.com>
Date: Tue, 19 Aug 2008 00:32:44 +0000
Subject: Re: [PATCHv2] dccp: Do not send Dccp-Sync after received	sequence-invalid
Message-Id: <48AA14AC.4080204@cn.fujitsu.com>
List-Id: <dccp.vger.kernel.org>
References: <48A91013.2010300@cn.fujitsu.com>
In-Reply-To: <48A91013.2010300@cn.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Eddie Kohler wrote:
> Gerrit Renker wrote:
>>> 7.5.4.  Handling Sequence-Invalid Packets
>>>
>>> o  A sequence-invalid DCCP-Reset packet MUST elicit a DCCP-Sync
>>>   packet in response (subject to a possible rate limit).  This
>>>   response packet MUST use a new Sequence Number, and thus will
>>>   increase GSS; GSR will not change, however, since the received
>>>   packet was sequence-invalid.  The response packet's
>>>   Acknowledgement Number MUST equal GSR.
>>>
>>> But reponse to a sequence-invalid DCCP-Reset with acknowledgement
>>> number equal to GSR will help to attack for sequence number. ...
> >
>> The requiremement of using GSR here is related to fixing another bug 
>> which
>> leads to a flood of Sync/Reset packets. A description of that bug is on
>> http://www.mail-archive.com/dccp@vger.kernel.org/msg01594.html
>
> Furthermore, Yongjun, I don't see how this is an "attack."  DCCP is 
> not robust against an attacker who can receive packets in the relevant 
> connection, such as the two DCCP-Syncs in your example.  Your attack 
> is out of the threat model.
>

I misunderstood the sequence number attack.^_^

Thanks

Wei Yongjun

