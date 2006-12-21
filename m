From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Thu, 21 Dec 2006 21:07:58 +0000
Subject: Re: [PATCH 4/5]: DCCP Fix t_nom
Message-Id: <200612212107.58665@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
References: <200612201548.12544.ian.mcdonald@jandi.co.nz>
In-Reply-To: <200612201548.12544.ian.mcdonald@jandi.co.nz>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Quoting Ian McDonald:
|  I'll look at this when I get a chance (hopefully today).

I will be out in a minute. I have few more things:

 (a) On
     http://www.erg.abdn.ac.uk/users/gerrit/dccp/patch-backlog/3c_CCID3_add_more_debugging_McDonald.diff
     I made minor changes (to make the format consistent)

 (b) On my `experimental' patch set I have uploaded the following:
     
     http://www.erg.abdn.ac.uk/users/gerrit/dccp/experimental_patches/EXPERIMENTAL_dummy_receiver.diff

     This short-circuits the feedback loop (when working as an electronics engineer,
     opening or short-circuiting was the first method of testing something when there
     was a fault). Using this patch, one can test if the sender `behaves', since the
     receiver practically does not impose inhibitions.

 (c) Thought again about dccp_wait_for_ccid -- is it certain that when the packet is ready
     to be sent (ccid_hc_tx_send_packet returns 0), that it indeed will be sent soon?
     I might ponder this when on holiday B-)

Best wishes
Gerrit
