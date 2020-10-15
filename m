From: Jakub Kicinski <kuba@kernel.org>
Date: Thu, 15 Oct 2020 03:42:30 +0000
Subject: Re: [PATCH 2/2] Revert "dccp: don't free ccid2_hc_tx_sock struct in dccp_disconnect()"
Message-Id: <20201014204230.56cbfb12@kicinski-fedora-pc1c0hjn.dhcp.thefacebook.com>
List-Id: <dccp.vger.kernel.org>
References: <20201013171849.236025-3-kleber.souza@canonical.com>
In-Reply-To: <20201013171849.236025-3-kleber.souza@canonical.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On Tue, 13 Oct 2020 19:18:49 +0200 Kleber Sacilotto de Souza wrote:
> From: Thadeu Lima de Souza Cascardo <cascardo@canonical.com>
> 
> This reverts commit 2677d20677314101293e6da0094ede7b5526d2b1.
> 
> This fixes an issue that after disconnect, dccps_hc_tx_ccid will still be
> kept, allowing the socket to be reused as a listener socket, and the cloned
> socket will free its dccps_hc_tx_ccid, leading to a later use after free,
> when the listener socket is closed.
> 
> This addresses CVE-2020-16119.
> 
> Fixes: 2677d2067731 (dccp: don't free ccid2_hc_tx_sock struct in dccp_disconnect())
> Reported-by: Hadar Manor

Does this person has an email address?

> Signed-off-by: Thadeu Lima de Souza Cascardo <cascardo@canonical.com>
> Signed-off-by: Kleber Sacilotto de Souza <kleber.souza@canonical.com>
