From: Eugen Dedu <Eugen.Dedu@pu-pm.univ-fcomte.fr>
Date: Fri, 27 Aug 2010 13:32:47 +0000
Subject: Re: DCCP_BUG called
Message-Id: <4C77BE7F.1020404@pu-pm.univ-fcomte.fr>
List-Id: <dccp.vger.kernel.org>
References: <4C6D3DD8.4080606@pu-pm.univ-fcomte.fr>
In-Reply-To: <4C6D3DD8.4080606@pu-pm.univ-fcomte.fr>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 27/08/10 13:45, Gerrit Renker wrote:
>> This needs a clarification.  Suppose a DCCPsocket with a size of a few
>> packets.  The current situation is the following:
>>
>> App --------->  DCCPsocket -------->  qdisc --------->  network
>>        3Mb/s                 3Mb/s     |     2Mb/s
>>                                        v
>>                                      1Mb/s rejected locally
>>
>> We believe that DCCP acts wrongly when it sends at 3Mb/s (identical to
>> appli speed).  It should have been:
>>
>> App --------->  DCCPsocket -------->  qdisc --------->  network
>>        3Mb/s        |        2Mb/s           2Mb/s
>>                     v
>>                   1Mb/s rejected because buffer is full
>>
>> Now, we have seen that DCCP correctly computes the estimated transmit
>> rate to 2Mb/s.  We believe this should be considered as DCCP (buffer)
>> output, not as network output.
>>
> I am not sure the above diagrams are correct. If TFRC sets a target bitrate
> of 2Mbps, it will also send at that rate. I have just done some tests that
> showed that the control of the output rate matches the expected value:
> http://www.erg.abdn.ac.uk/users/gerrit/dccp/notes/ccid3/sender_notes/rate_mismatch_controller/
>
> Hence in the first diagram the input rate at the qdisc input would be 2Mpbs, not
> 3Mbps. But it is difficult to argue without testing, and as Ian pointed out, it
> is not such a good idea to run the traffic shaper on the same box as the sender.
>
> As per previous email, before drawing conclusions as above, I would really like to
> encourage you to use dccp_probe. You are testing only one paramter, the computed
> allowed sending rate X. This leaves out the current value of the loss rate p,
> the computed sending rate X_calc, and the sending rate estimated at the receiver,
> X_recv.
>
> Plus, using getsockopt is very unreliable for polling information, since it always
> involves at least the overhead of a system call.
>
> Before suggesting that there is a bug here, please consider your setup.

Ok, I think you are right.  Thank you for this discussion.

>> Thank you, we have finally used a middlebox, and shaping works (well,
>> there are from time to time intervals of 1 second where the receiver
>> receives twice more packets than middlebox's qdisc would allow, but we
>> need to investigate further this strange issue).
>>
> In theory the limit that TFRC can control is 12Mbps (MTU00, HZ00),
> at speeds higher than that it will send bursts where the momentaneous
> speed can be much higher.

Thank you for the information, I didn't know that.

Cheers,
-- 
Eugen
