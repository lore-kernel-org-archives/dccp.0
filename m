From: Patrick McHardy <kaber@trash.net>
Date: Tue, 08 Apr 2008 16:21:59 +0000
Subject: Re: DCCP conntrack/NAT
Message-Id: <47FB9BA7.6080500@trash.net>
List-Id: <dccp.vger.kernel.org>
References: <47F64C0D.5080700@trash.net>
In-Reply-To: <47F64C0D.5080700@trash.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Patrick McHardy wrote:
> I've added this patch on top to handle the out-of-sync case by
> letting Requests pass in (almost) any state and resyncing when
> seeing a valid Response.
> 
> Last TODO before the DCCP_LISTEN support is to fix connection
> pickup for established connections. Since it doesn't see the
> initial Request/Response it doesn't know which side has which
> role and also can't properly pick an inital state.

I skipped this for now since it gets a bit ugly and is
not very important for an initial version. I'm uploading
my current tree to kernel.org now, should be there within
the next 20 minutes.

I'll post a patch for DCCP_LISTEN soon (not sure if I will
manage to get it ready today though).

