From: Gorry Fairhurst <gorry@erg.abdn.ac.uk>
Date: Tue, 27 Mar 2007 10:58:54 +0000
Subject: Re: [dccp] [Fwd: New Version Notification - draft-fairhurst-dccp-serv-codes-03.txt]
Message-Id: <4608F8EE.6090605@erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
References: <5640c7e00703241429i1314d092lf4aa29317e4b9c92@mail.gmail.com>
In-Reply-To: <5640c7e00703241429i1314d092lf4aa29317e4b9c92@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Thanks,

When it comes to use htonl/ntohl with a socket opt, I guess others may 
have more clue than me... please do also reply!

See in-line.

Gorry

Ian McDonald wrote:

> On 3/6/07, Gorry Fairhurst <gorry@erg.abdn.ac.uk> wrote:
> 
>> I have updated this I-D with corrections received from others and some
>> new additions to section 4.
>>
>> Comments and questions are welcome...
>>
>> best wishes,
>>
>> Gorry
>>
>> ---
>>
>> draft-fairhurst-dccp-serv-codes-03.txt.
>> http://www.ietf.org/internet-drafts/draft-fairhurst-dccp-serv-codes-03.txt 
>>
>>
> 
> After debugging why iperf with service codes didn't work between a ppc
> eMac and an i386 machine I've got a comment to make on endian issues.
> 
I'll add something, to remind people that the Spec uses 
network-byte-order (this can only do good!).
 >
> I think that in section 5 we need to talk about host vs network order.
> In Linux at present we set the service code by a setsockopt and if it
> is not wrapped by htonl/ntohl then it will fail with bad service code
> on establishing the connection.
> 
> The question is where should we do the translation from network to host 
> order?
> 
> If we look at use of struct sockaddr_in in *nix that already uses
> htons for ports. If we were to extend this structure for service codes
> I think we should be consistent with that. However I'm not sure when
> it comes to socket options whether this is the right thing to do or
> not and would appreciate peoples feedback.
 >
Can anyone help give some good practice here?
> 
> I think the right thing to do over time is actually not to use socket
> options anyway but modify getaddrinfo as suggested. This would imply
> (to me at least) that we would need to add an additional field into
> /etc/services for the service code. Also other functions such as
> getnameinfo and getservent would need to be looked at - as suggested
> by my colleague Perry Lorier.
 >
This seems like a sensible thing to think about.
> 
> To do this in /etc/services we would need to add a field for service
> code although this is interesting with aliases being the last field
> and there being multiple so two possible solutions I can think of:
> - if protocol dccp then put another slash and service code e.g. iperf
> 5001/dccp/PERF
> - put it in another file
> 
> I prefer the first of the two as just one file and the change to
> format shouldn't break any existing apps due to only being used with
> dccp but we'd need to test.
 >
If I understand correctly these are both "Standard Support" as in 4.2
- and they would have constraints on only one port per Service Code
specified in the file.
- This seems a reasonable first step.
- If we envisage a later move to a more flexible arch. (4.3), then a 
separate file may be the way to finally go?

I'm interested in what people think is best? and what issues there are!
> 
> I would appreciate more discussion on this as we work together to sort
> the API. Hopefully we can do it in a manner that will work across
> Unix/Linux and BSD variants.
 >
Yes - with inputs from other OS if we can find them!!!!

> I'm far from an expert (actually a novice
> network programmer) but I'm prepared to add a few more words to the
> document once there's more discussion to what I've just said.
> 
Please do. This seems like good info to develop and add to section 4.

> Ian


