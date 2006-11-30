From: "Arnaldo Carvalho de Melo" <arnaldo.melo@gmail.com>
Date: Thu, 30 Nov 2006 22:33:59 +0000
Subject: Re: [BUG] CCID3 performance is f**ked
Message-Id: <39e6f6c70611301433s1c809a49p8a385fd349a5e924@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <5640c7e00611301425v1c0c4b07kfeace18480cd0039@mail.gmail.com>
In-Reply-To: <5640c7e00611301425v1c0c4b07kfeace18480cd0039@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 11/30/06, Ian McDonald <ian.mcdonald@jandi.co.nz> wrote:
> Folks,
>
> CCID3 is fucked up. Sorry to put it this way but thats how I feel.
>
> With 2.6.19rc6 plus the patches from
> http://wand.net.nz/~iam4/dccp/patches/ it works fine. (The only
> significant patch here is tx_qlen - all the rest should have no
> impact).
>
> So here are the stats using iperf:
> Test                                             2.6.19rc6+ian
> 2.6.20-acme20
> Direct connect                                87 Mbits             36 Mbits
> Through a Linux router (1.2 ms rtt)    36 Mbit               200 kbits
> (yes that is correct!)
> Through netem (100 ms rtt, 5% loss)  130 kbits           116 kbits (OK)
>
> So somewhere on low rtt links we've stuffed up.
>
> Below is the logs from the receiver from when performance dropped from
> 36 Mbit to 200 kbits. The illegal ACKs are documented in another email
> and I don't think are the problem. The issue I suspect is that it says
> rtt is around 12000 usecs which is 12 msec and it is really 1.2
> msecs....
>
> I can't look at this for a while as have to go to work and have my
> kids over this weekend. I'll start bisecting next week if I can if
> nobody else has fixed.
>
> Can I suggest that people test CCID3 on a range of loss, rtt
> combinations please? CCID3 has proven time after time to be very
> sensitive....

As I told you, I'm preparing a more comprehensive test environment
here, just being sidetracked by some problems using net-2.6.20 on a
parisc64 machine.

- Arnaldo
