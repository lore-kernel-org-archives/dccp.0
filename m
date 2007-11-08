From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Thu, 08 Nov 2007 10:24:34 +0000
Subject: Re: [PATCH 12/25] Share TFRC receiver states via tfrc_ccids
Message-Id: <20071108102434.GD11792@gerrit.erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
References: <200710312131.13219.leandroal@gmail.com>
In-Reply-To: <200710312131.13219.leandroal@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Another candidate: both translate the same enum into strings.
| +static const char *ccid4_rx_state_name(enum tfrc_hc_rx_states state)
|  {
|  	static char *ccid4_rx_state_names[] = {
|  	[TFRC_RSTATE_NO_DATA] = "NO_DATA",

| +static const char *ccid3_rx_state_name(enum tfrc_hc_rx_states state)
|  {
|  	static char *ccid3_rx_state_names[] = {
|  	[TFRC_RSTATE_NO_DATA] = "NO_DATA",
