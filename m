From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Mon, 02 Apr 2007 13:13:00 +0000
Subject: Re: [PATCH 0/9] DCCP: Revised patchset
Message-Id: <200704021413.00846@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
References: <200703231502.22447.ian.mcdonald@jandi.co.nz>
In-Reply-To: <200703231502.22447.ian.mcdonald@jandi.co.nz>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

|  This is a revised set of patches sent from yesterday
Thank you for the update. I went through each patch again and it blends in
fine with the set of patches that follow.

Many patches are later overridden, so only the copyright patch stands out
clearly. The other patches are `overlaid' because

 * there is a new loss interval history which allocates on-demand. This
   has been rewritten and deals with loss intervals < 8 (as per announcement);
 * the loss detection has been rewritten from scratch and (not boasting)
   deals with losses of the same window / re-ordering / recycling of loss history /
   loss burst (also as per earlier email)

Test modules can be supplied for the new infrastructure, which I'd submit tomorrow
or the day after if this is ok.
(Info page: http://www.erg.abdn.ac.uk/users/gerrit/dccp/docs/ccid3_packet_reception/ )

Many thanks
Gerrit
