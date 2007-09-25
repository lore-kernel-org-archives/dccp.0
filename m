From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Date: Tue, 25 Sep 2007 23:09:45 +0000
Subject: Re: [PATCH 8/8]: Support inserting options during the 3-way handshake
Message-Id: <5640c7e00709251609m7bd19840nb8ac2a29b80f724@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <200709251530.51394@strip-the-willow>
In-Reply-To: <200709251530.51394@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 9/26/07, Gerrit Renker <gerrit@erg.abdn.ac.uk> wrote:
> [DCCP]: Support inserting options during the 3-way handshake
>
> This provides a separate routine to insert options during the initial handshake.
> The main purpose is to conduct feature negotiation, for the moment the only user
> is the timestamp echo needed for the (CCID3) handshake RTT sample.
>
> Padding of options has been put into a small separate routine, to be shared among
> the two functions. This could also be used as a generic routine to finish inserting
> options.
>
> Also removed an `XXX' comment since its content was obvious.
>
> Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>

Signed-off-by: Ian McDonald <ian.mcdonald@jandi.co.nz>
Once the tse pointer issue is shifted - I noticed this in this patch,
but not original. I must only be half as smart as Arnaldo ;-)
-- 
Web1: http://wand.net.nz/~iam4/
Web2: http://www.jandi.co.nz
Blog: http://iansblog.jandi.co.nz
