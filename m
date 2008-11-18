From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Date: Tue, 18 Nov 2008 17:41:08 +0000
Subject: Re: [RFC] dccp ccid-3: High-res or low-res timers?
Message-Id: <5640c7e00811180941l671fd3a0w390529df9222163e@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <20081115105042.GA7798@gerrit.erg.abdn.ac.uk>
In-Reply-To: <20081115105042.GA7798@gerrit.erg.abdn.ac.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On Tue, Nov 18, 2008 at 7:14 PM, Gerrit Renker <gerrit@erg.abdn.ac.uk> wrote:
> | The RFC uses an example of 1 msec scheduling and 0.1 msec RTT. However
> | what would be worse is devices on a LAN with 10 msec timer - e.g. two
> | embedded devices at home - I haven't done the maths but I think the
> | rate achievable would be quite low.
> If we use lower-resolution timers I think there should be a
> recommendation (in the Kconfig menu for instance) not to use
> low HZ values.
>
> Previously this was done as a build warning, but it is annoying if
> people do an allmodconfig and are not otherwise interested in DCCP.
>
Agree

> Do you think we could live with clamping the RTT to some sensible
> minimum, since on a local LAN the use of congestion control is
> questionable? I was thinking in the order of 0.5 ... 1msec.
>
I think that is a good idea - if 1 msec, and HZ = 1000 then we
wouldn't lose any transmission capability.

> | Thinking laterally there is another possible solution - something I
> | used way back in the 80s for another project - build your own
> | scheduler! We could set a high resolution timer to tick every 0.1 msec
> | and then use the coarse grained algorithm at that point....
> |
> So we have three possible options - timer-based (low/high), and your
> suggestion above. We can keep these variants open by spawning an
> experimental subtree which provides an alternative implementation, so
> that people could explore alternative algorithms, compare and send patches.
>
> For production use the low-resolution variant is the simplest and less
> expensive option, and it is good that there is consensus about it.
>
Yes - and with your RTT clamping then no need to do my idea around scheduler.

> In a discussion about two years ago there was another
> idea, doing away with the nofeedback timer, by checking the nofeedback
> time at the instant a packet is sent.
>
I think this is useful as reduces the amount of timers going off,
which reduces system load.

-- 
Web: http://wand.net.nz/~iam4/, http://www.jandi.co.nz
Blog: http://iansblog.jandi.co.nz
