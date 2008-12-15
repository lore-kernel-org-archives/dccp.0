From: gerrit@erg.abdn.ac.uk
Date: Mon, 15 Dec 2008 16:25:46 +0000
Subject: Re: [PATCH 2/5] dccp: Auto-load (when supported) CCID plugins for
Message-Id: <36660.148.187.160.35.1229358346.squirrel@148.187.160.35>
List-Id: <dccp.vger.kernel.org>
References: <1229175685-18716-3-git-send-email-gerrit@erg.abdn.ac.uk>
In-Reply-To: <1229175685-18716-3-git-send-email-gerrit@erg.abdn.ac.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

> Since the lock is dropped after checking ccids[id] then there's
> a window where multiple request_module()s can be called if multiple
> applications create a DCCP socket at a same time. The code below
> should do the same without a lock (ccids is a static array,
> so ccids[N] is always at the same place).
>
> static int ccid_request_module(u8 id)
> {
>        if (!in_atomic()) {
>                rmb();
>                if (ccids[id] = NULL)
>                        return request_module("net-dccp-ccid-%d", id);
>        }
>        return 0;
> }
>
I think that the code (not yours) is in general misleading. It stems from
an earlier phase of the DCCP development. Now, with the present patch set,
the rationale is
 * all CCIDs that are advertised must be loaded
 * this is a subset of the configured CCIDs and contains at least one CCID
 * the request_module is only ever executed once, when the first DCCP
   application tries to pre-load the CCIDs it wants to advertise

Hence I think we have a chance by going completely lockless here, by
loading all configured CCIDs at runtime. In this manner the per-connection
check "are all advertised CCIDs are loaded?" falls under the table, we
do not need to worry about concurrent access, and loading DCCP implies that
all needed CCIDs are there.

Arnaldo would you be okay with such an approach ? I would be willing to
revise the patch set accordingly.

Gerrit

