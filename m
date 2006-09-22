From: Arnaldo Carvalho de Melo <acme@mandriva.com>
Date: Fri, 22 Sep 2006 14:00:26 +0000
Subject: Re: [PATCH 3/7] [DCCP]: Introduce dccp_probe
Message-Id: <20060922140025.GC1828@mandriva.com>
List-Id: <dccp.vger.kernel.org>
References: <200609221428.02022.ian.mcdonald@jandi.co.nz>
In-Reply-To: <200609221428.02022.ian.mcdonald@jandi.co.nz>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On Fri, Sep 22, 2006 at 02:28:01PM +1200, Ian McDonald wrote:
> This adds DCCP probing shamelessly ripped off from TCP probes by Stephen
> Hemminger.
> 
> I've put in here support for further CCID3 variables as well.
> Andrea/Arnaldo might look to extend for CCID2.
> 
> Signed-off-by: Ian McDonald <ian.mcdonald@jandi.co.nz>

Applied after renaming net/dccp/dccp_probe.c to net/dccp/probe.c for
consistency, the resulting module remains dccp_probe.ko

I guess we should try at some point to consolidate the code in these
probes tho.

- Arnaldo
