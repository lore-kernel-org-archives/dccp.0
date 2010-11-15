From: David Miller <davem@davemloft.net>
Date: Mon, 15 Nov 2010 19:04:59 +0000
Subject: Re: net-next-2.6 [PATCH 0/6]: dccp ccid-2: Ack Vector patch set
Message-Id: <20101115.110459.68121782.davem@davemloft.net>
List-Id: <dccp.vger.kernel.org>
References: <1289802547-5617-1-git-send-email-gerrit@erg.abdn.ac.uk>
In-Reply-To: <1289802547-5617-1-git-send-email-gerrit@erg.abdn.ac.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Mon, 15 Nov 2010 07:29:01 +0100

> Hi Dave,
> 
> please find attached part II of the Ack Vector patch set, concluding
> the submission (part I) begun last week.
> 
>  Patch #1: algorithm to update/clear Ack Vector state in the circular buffer.
>  Patch #2: algorithm to register new packets as received in the circular buffer.
>  Patch #3: consolidates/updates Ack Vector processing in the main DCCP module.
>  Patch #4: schedules DCCP-Sync in case there is no space left for Ack Vectors.
>  Patch #5: removes the replaced parts of the old Ack Vector infrastructure.
>  Patch #6: Ack Vectors provide information specific to CCIDs; this patch thus
>            moves Ack Vector processing from main DCCP into the CCID module(s).
>  
> 
> I have also placed this in into a fresh (today's) copy of net-next-2.6, on
> 
>     git://eden-feed.erg.abdn.ac.uk/net-next-2.6        [subtree 'dccp']

Pulled, thanks a lot Gerrit.

Some of the new functions you added had some coding style quirks,
for example the openning brace for dccp_ackvec_clear_state()
has an unnecessary space before it on that line.

Please fix those sorts of things up, thanks.
