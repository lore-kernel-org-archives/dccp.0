From: David Miller <davem@davemloft.net>
Date: Mon, 17 Nov 2008 06:57:05 +0000
Subject: Re: [PATCH 5/5] dccp: Tidy up setsockopt calls
Message-Id: <20081116.225705.57687104.davem@davemloft.net>
List-Id: <dccp.vger.kernel.org>
References: <1226751079-15019-6-git-send-email-gerrit@erg.abdn.ac.uk>
In-Reply-To: <1226751079-15019-6-git-send-email-gerrit@erg.abdn.ac.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Sat, 15 Nov 2008 13:11:19 +0100

> This splits the setsockopt calls into two groups, depending on whether an
> integer argument (val) is required and whether routines being called do
> their own locking.
> 
> Some options (such as setting the CCID) use u8 rather than int, so that for
> these the test with regard to integer-sizeof can not be used.
> 
> The second switch-case statement now only has those statements which need
> locking and which make use of `val'.
> 
> Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
> Acked-by: Ian McDonald <ian.mcdonald@jandi.co.nz>
> Acked-by: Arnaldo Carvalho de Melo <acme@redhat.com>
> Reviewed-by: Eugene Teo <eugeneteo@kernel.sg>

Applied.
