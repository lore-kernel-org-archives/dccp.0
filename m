From: Andrew Lunn <andrew@lunn.ch>
Date: Wed, 28 Oct 2020 01:20:47 +0000
Subject: Re: [PATCH net-next] net: dccp: Fix most of the kerneldoc warnings
Message-Id: <20201028012047.GB931318@lunn.ch>
List-Id: <dccp.vger.kernel.org>
References: <20201028011412.931250-1-andrew@lunn.ch>
In-Reply-To: <20201028011412.931250-1-andrew@lunn.ch>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

There are two W=1 warnings left after this patch is applied:

net/dccp/ccids/ccid2.c:365: warning: Function parameter or member 'mrtt' not described in 'ccid2_rtt_estimator'
net/dccp/ccids/lib/tfrc_equation.c:695: warning: Function parameter or member 'loss_event_rate' not described in 'tfrc_invert_loss_event_rate'

It would be nice is somebody could fix those as well.

   Andrew
