From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Wed, 05 Dec 2007 13:45:18 +0000
Subject: Re: [RFC][PATCHES 0/7]: Reorganization of RX history patches
Message-Id: <20071205134518.GC893@gerrit.erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
References: <1196631416-17778-1-git-send-email-acme@redhat.com>
In-Reply-To: <1196631416-17778-1-git-send-email-acme@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

| > Patch #3: 
| > ---------
| >   Renames s/tfrc_tx_hist/tfrc_tx_hist_slab/g; no problems.
| 
| This was for consistency with the other slabs in DCCP:
| 
| [acme@doppio net-2.6.25]$ find net/dccp/ -name "*.c" | xargs grep 'struct kmem_cache'
Thanks, I will put the same naming scheme also in the test tree (tomorrow).

 
| > Patch #4:
| > ---------
| > Just a suggestion, it is possible to simplify this further,
| >   by doing all the initialisation / cleanup in tfrc.c:
| >     int __init {rx,tx}_packet_history_init()
| >     {
| > 	    tfrc_{rx,tx}_hist_slab = kmem_cache_create("tfrc_{rx,tx}_hist", ...);
| > 	    return tfrc_{rx,tx}_hist_slab = NULL ? - ENOBUFS : 0;
| >     }
| >   and then call these successively in tfrc_module_init().
| 
| Idea here was to have each C source file to have a init module. Perhaps
| we should try to break packet_history.c into tx_packet_history and
| rx_packet_history.c. We can do that later to try to meet the goal of
| being able to see what is being replaced.
|
I think this is a great idea, since then rx_packet_history.c could also
take up all the internals of the RX packet history list, as it is
currently done for the TX history, and it could also possibly
incorporate. packet_history_internal.h.


|  
| > Patch #7:
| > ---------
|  
| >  * tfrc_rx_hist_entry_data_packet() is not needed:
| >    - a similar function, called dccp_data_packet(), was introduced in patch 2/7
| 
| I thought about that, but dccp_data_packet is for skbs,
| tfrc_rx_hist_entry_data_packet is for tfrc_rx_hist_entries, I guess we
| should just make dccp_data_packet receive the packet type and not an
| object that has a packet type field.
| 
The question which of the two interfaces is generally better to use is
best left to you. Two functions doing almost the same thing can probably
be replaced by just one.
