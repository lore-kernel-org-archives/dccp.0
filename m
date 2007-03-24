From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Date: Sat, 24 Mar 2007 21:29:24 +0000
Subject: Re: [dccp] [Fwd: New Version Notification - draft-fairhurst-dccp-serv-codes-03.txt]
Message-Id: <5640c7e00703241429i1314d092lf4aa29317e4b9c92@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 3/6/07, Gorry Fairhurst <gorry@erg.abdn.ac.uk> wrote:
> I have updated this I-D with corrections received from others and some
> new additions to section 4.
>
> Comments and questions are welcome...
>
> best wishes,
>
> Gorry
>
> ---
>
> draft-fairhurst-dccp-serv-codes-03.txt.
> http://www.ietf.org/internet-drafts/draft-fairhurst-dccp-serv-codes-03.txt
>

After debugging why iperf with service codes didn't work between a ppc
eMac and an i386 machine I've got a comment to make on endian issues.

I think that in section 5 we need to talk about host vs network order.
In Linux at present we set the service code by a setsockopt and if it
is not wrapped by htonl/ntohl then it will fail with bad service code
on establishing the connection.

The question is where should we do the translation from network to host order?

If we look at use of struct sockaddr_in in *nix that already uses
htons for ports. If we were to extend this structure for service codes
I think we should be consistent with that. However I'm not sure when
it comes to socket options whether this is the right thing to do or
not and would appreciate peoples feedback.

I think the right thing to do over time is actually not to use socket
options anyway but modify getaddrinfo as suggested. This would imply
(to me at least) that we would need to add an additional field into
/etc/services for the service code. Also other functions such as
getnameinfo and getservent would need to be looked at - as suggested
by my colleague Perry Lorier.

To do this in /etc/services we would need to add a field for service
code although this is interesting with aliases being the last field
and there being multiple so two possible solutions I can think of:
- if protocol dccp then put another slash and service code e.g. iperf
5001/dccp/PERF
- put it in another file

I prefer the first of the two as just one file and the change to
format shouldn't break any existing apps due to only being used with
dccp but we'd need to test.

I would appreciate more discussion on this as we work together to sort
the API. Hopefully we can do it in a manner that will work across
Unix/Linux and BSD variants. I'm far from an expert (actually a novice
network programmer) but I'm prepared to add a few more words to the
document once there's more discussion to what I've just said.

Ian
-- 
Web: http://wand.net.nz/~iam4
Blog: http://iansblog.jandi.co.nz
WAND Network Research Group
