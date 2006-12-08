From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Fri, 08 Dec 2006 13:04:58 +0000
Subject: Re: [Patchv2 4/12]: Deprecate ccid3_hc_tx_insert_options
Message-Id: <200612081304.58687@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
References: <200612081150.06793@strip-the-willow>
In-Reply-To: <200612081150.06793@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

|  If in the future CCID9 needs a hook for this, we add it in the
|  infrastructure, no need to overengineer right now, agreed?
OK, will re-submit v3 in some time from now. Working on the last two ones at the moment,
they need overhaul due to the kmem_cache things which have changed in Dave's latest kernel.
