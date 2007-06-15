From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Fri, 15 Jun 2007 08:53:01 +0000
Subject: Re: [PATCH 5/5]: Provide central source file and debug facility
Message-Id: <200706150953.01462@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
References: <200706141005.25979@strip-the-willow>
In-Reply-To: <200706141005.25979@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Ian McDonald wrote:
|  > The first serves to make the source code structure clearer, since module
|  > initialisation and module parameter statements are currently spread over
|  > loss_interval.c and packet_history.c (which are part of the tfrc_lib).
|  
|  Do you intend to get rid of either of these or are we just increasing
|  number of files?
By no means - the organisation of the source files is fine: packet_history.c
does one thing and not another, and so do tfrc_equation.c and loss_interval.c.

The point is that each of these files does something specific.

The added file is therefore more of a binder: aggregating those files which serve 
only a specific purpose. 

During the course of the the next patches, initialisation and cleanup routines will follow.

Further module parameters and module documentation can also be added to this file.
