From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Tue, 09 Oct 2007 09:51:45 +0000
Subject: Re: DCCP feature negotiation via setsockopt/getsockopt
Message-Id: <200710091051.45415@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
References: <5bc4c4570710081913hd9abfdek5bee586393ef1f72@mail.gmail.com>
In-Reply-To: <5bc4c4570710081913hd9abfdek5bee586393ef1f72@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

|   In the gstreamer plugin I want to provide a plugin property named
|  ccid, where the programmer will set or get the current ccid. Is dccp
|  implementation for linux already prepared to support this mechanism
|  through feature negotiation (or something related via
|  setsockopt/getsockopt)?
Yes it is - all the necessary code is in the test tree, but it is not
exhaustively documented so far (but all set/getsockopts are documented
in Documentation/networking/dccp.txt).

Here is a short test program to document:

/*----------------------------------------------------------------------------------------------*/
#include <err.h>

uint8_t    ccid = 3, 		/* the CCID you want to set */
	   ccids[4],		/* for getting the available CCIDs, should be large enough */
           tx_ccid, rx_ccid;
socklen_t  len = sizeof(ccids);
int        sockfd = socket(AF_XXX, SOCK_DCCP, 0);

/*
 * Determine which CCIDs are available on the host 
 */
if (getsockopt(sockfd, SOL_DCCP, DCCP_SOCKOPT_AVAILABLE_CCIDS, &ccids, &len) < 0)
                err(1, "Can not determine available CCIDs");

ccid = my_favourite_ccid;
if (!found_in_array(ccid, ccids, sizeof(ccids))
	err(1, "CCID %d not supported", ccid);

/* 
 * The following calls need to be made before establishing the connection, i.e. before
 * calling listen() or connect() 
 */

if (setsockopt(sockfd, SOL_DCCP, DCCP_SOCKOPT_CCID, &ccid, sizeof(ccid)) < 0)
                err(1, "Can not set CCID");

/*
  Alternatively, if you want to set different CCIDs for each direction:
  if (setsockopt(sockfd, SOL_DCCP, DCCP_SOCKOPT_TX_CCID, &tx_ccid, sizeof(tx_ccid)) < 0)
                err(1, "Can not set TX CCID");

  if (setsockopt(sockfd, SOL_DCCP, DCCP_SOCKOPT_RX_CCID, &rx_ccid, sizeof(rx_ccid)) < 0)
                err(1, "Can not set RX CCID");

  NOTE: In the above, single values are used. If you want choice, you can pass an ordered
        array (preferred CCID first), which will then be used for feature-negotiation.
        If you are negotiating with single values, it will only work when both sides pick
        the same value.
 */

/*
 * Once the connection is established, you can find out the results of the feature negotiation
 * by calling getsocktopt() with DCCP_SOCKOPT_TX_CCID/DCCP_SOCKOPT_RX_CCID
 */

/*----------------------------------------------------------------------------------------------*/

Looking forward to the gstreamer plugin - can you please announce on the list.
