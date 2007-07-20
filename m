From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Date: Fri, 20 Jul 2007 20:41:43 +0000
Subject: Re: iperf
Message-Id: <5640c7e00707201341h77708ea5n1da649ed32ce5a77@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <5bc4c4570707171213v6eb89545y5970e471345cc3f8@mail.gmail.com>
In-Reply-To: <5bc4c4570707171213v6eb89545y5970e471345cc3f8@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 7/21/07, Gerrit Renker <gerrit@erg.abdn.ac.uk> wrote:
> |  OK. I've hacked my iperf version around a bit to get closer to Gerrit's.
> |
> |  What I've done:
> |  - ported more of his code over
> |  -- renaming/shifting code
> |  -- fix service code handling to allow network byte order and correct name
> |  -- merged using -b option for DCCP (NB gives an error at end but seems
> |  to be working OK)
> This is an error - you need to support the -b option on the server as well. The
> reason is that iperf, like ttcp, uses a kind of handshake to terminate datagram
> test runs. You didn't describe the error - was it something like `did not receive the
> last ack after 10 tries'? If yes then the code needs to support -b on the server
> as well. The bandwidth measurements are otherwise not accurate.

Yes it was. That makes sense now.
>
> |
> |  Our code still differs a bit e.g. I don't support UDP Lite yet.
> Are these the only differences? If yes then I am all for combining one patch
> and uploading it to the description of regression testing.
>
Yes it was, apart from I hadn't picked up all your tidyups.

-- 
Web: http://wand.net.nz/~iam4/
Blog: http://iansblog.jandi.co.nz
WAND Network Research Group
