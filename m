From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Thu, 28 Jun 2007 13:51:42 +0000
Subject: Re: [PATCH 8/9]: Fix and simplify header includes
Message-Id: <200706281451.42925@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
References: <200706171354.38717@strip-the-willow>
In-Reply-To: <200706171354.38717@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Ian McDonald wrote:
|  > +/* internal includes that this module exports: */
|  > +struct tfrc_rx_hist;
|  > +struct tfrc_loss_hist;
|  > +#include "loss_interval.h"
|  > +#include "packet_history.h"
|  >
|  
|  Variable definitions in the middle of an include block? Is that
|  necessary? I just haven't seen that done before and it looks a little
|  odd...
|  
You are right, that is ugly, which is why I have changed it - see subsequent patch.
The forward declarations of the two structures are needed since both sub-units --
receiver history and (receiver) loss detection work tightly together

 * the RX history does loss detection and needs to know where to pass on a newly 
   identified loss. This is done by tfrc_rx_handle_loss() which talks to struct tfrc_loss_hist.

 * the loss interval database needs to access information stored in the receiver history
   record when creating a new loss interval, to identify whether a loss event starts a new
   loss interval, and for several internal uses. This is done in tfrc_lh_interval_add(),
   which talks to struct tfrc_loss_hist.
