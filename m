From: Jakub Kicinski <kuba@kernel.org>
Date: Mon, 09 Nov 2020 22:15:53 +0000
Subject: Re: [PATCH 1/2] dccp: ccid: move timers to struct dccp_sock
Message-Id: <20201109141553.30e9d502@kicinski-fedora-PC1C0HJN.hsd1.ca.comcast.net>
List-Id: <dccp.vger.kernel.org>
References: <20201013171849.236025-2-kleber.souza@canonical.com>
In-Reply-To: <20201013171849.236025-2-kleber.souza@canonical.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On Mon, 9 Nov 2020 18:31:34 -0300 Thadeu Lima de Souza Cascardo wrote:
> > Which paths are those (my memory of this code is waning)? I thought
> > disconnect is only called from the user space side (shutdown syscall).
> > The only other way to terminate the connection is to close the socket,
> > which Eric already fixed by postponing the destruction of ccid in that
> > case.  
> 
> dccp_v4_do_rcv -> dccp_rcv_established -> dccp_parse_options ->
> 	dccp_feat_parse_options -> dccp_feat_handle_nn_established ->
> 	dccp_feat_activate -> __dccp_feat_activate -> dccp_hdlr_ccid ->
> 	ccid_hc_tx_delete

Well, that's not a disconnect path.

There should be no CCID on a disconnected socket, tho, right? Otherwise
if we can switch from one active CCID to another then reusing a single
timer in struct dccp_sock for both is definitely not safe as I
explained in my initial email.
