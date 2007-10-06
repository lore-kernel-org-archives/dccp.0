From: Eddie Kohler <kohler@cs.ucla.edu>
Date: Sat, 06 Oct 2007 21:55:06 +0000
Subject: Re: DCCP support in VLC
Message-Id: <4708043A.3010005@cs.ucla.edu>
List-Id: <dccp.vger.kernel.org>
References: <200709271930.03854.rdenis@simphalempin.com>
In-Reply-To: <200709271930.03854.rdenis@simphalempin.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

A quick note on half-close.

The DCCP state machine has no half-closed state, but the Data Dropped option's 
Drop Code 1, "Application Not Listening", can be used like a TCP 
shutdown-for-receive.

Eddie


Gorry Fairhurst wrote:
> Gerrit Renker wrote:
>> |  > When the Reset closing the connection arrives, the same shutdown 
>> mask is
>> |  > set as in TCP. What I thus think you could do as a
>> |  > test-for-end-of-connection is to test whether the socket 
>> descriptor is
>> |  > still read/writeable.
>> |  |  If it works like TCP, shutdown-for-recv will make the socket 
>> always readable, |  and will not affect writeability at all, since the 
>> sending half may still be |  open. As such, I don't think it will 
>> solve the problem.
>> DCCP has no half-close (RFC 4340, 4.6), so closing the socket shuts 
>> down both the
>> read and the write end (i.e. SHUT_RDWR is set by the kernel) - you 
>> could test for this.
>>
>> |  Currently, I am assuming that length = 0 means end-of-connection, 
>> because I |  only use RTP/RTCP, so zero bytes is not a valid packet 
>> length. But that's a |  little bit ugly.
>> It would be better to use a different solution. 
>  >
> I agree.
> 
>> There has also been discussion to use
>> 0-sized packets for keep-alive or congestion messages 
>  > (I hope that this remains talk only).
>>
> It's my understanding that the use of zero-length DATA packets as 
> transport-layer
> keep alives (to probe for congestion status) was removed from the Faster 
> Restart proposal at the last IETF DCCP WG meeting.
> This use was omitted from the latest revision of the FR draft.
> 
> However, DCCP still does allow the application to send zero-sized DATA 
> from the API, just as UDP currently permits. (You may never wish to use 
> this if you have an application layered over RTP.)
> 
> Gorry
> -
> To unsubscribe from this list: send the line "unsubscribe dccp" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
