From: "Arnaldo Carvalho de Melo" <acme@ghostprotocols.net>
Date: Thu, 12 Apr 2007 15:36:02 +0000
Subject: Re: [PATCH 19/25]: Remove unused fields in packet history structure
Message-Id: <39e6f6c70704120836s61a8d0eh44ed9bd1396d25b3@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <200703211845.41809@strip-the-willow>
In-Reply-To: <200703211845.41809@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 3/26/07, Ian McDonald <ian.mcdonald@jandi.co.nz> wrote:
> On 3/22/07, Gerrit Renker <gerrit@erg.abdn.ac.uk> wrote:
> > [CCID 3]: Remove unused fields in packet history structure
> >
> Acked-by: Ian McDonald <ian.mcdonald@jandi.co.nz>

Indeed it reduced the size:

[acme@mica net-2.6.22]$ cat /tmp/before
/* <eb7c> /home/acme/git/net-2.6.22/net/dccp/ccids/lib/packet_history.h:55 */
struct dccp_tx_hist_entry {
        struct list_head           dccphtx_node;         /*     0    16 */
        u64                        dccphtx_seqno:48;     /*    16     8 */
        u64                        dccphtx_sent:1;       /*    16     8 */

        /* XXX 15 bits hole, try to pack */

        u32                        dccphtx_rtt;          /*    24     4 */

        /* XXX 4 bytes hole, try to pack */

        struct timeval             dccphtx_tstamp;       /*    32    16 */
}; /* size: 48, cachelines: 1 */
   /* sum members: 44, holes: 1, sum holes: 4 */
   /* bit holes: 1, sum bit holes: 15 bits */
   /* last cacheline: 48 bytes */
[acme@mica net-2.6.22]$ pahole -e
../build/mica/net-2.6.22/net/dccp/ccids/ccid3.o dccp_tx_hist_entry /*
<eb7c> /home/acme/git/net-2.6.22/net/dccp/ccids/lib/packet_history.h:55
*/
struct dccp_tx_hist_entry {
        struct list_head           dccphtx_node;         /*     0    16 */
        u64                        dccphtx_seqno;        /*    16     8 */
        struct timeval             dccphtx_tstamp;       /*    24    16 */
}; /* size: 40, cachelines: 1 */
   /* last cacheline: 40 bytes */
[acme@mica net-2.6.22]$

I wonder if we could make this a single linked list, lemme see.. I
think so, and by doing that we get the struct down to 32 bytes, making
it cacheline friendly, and also simplify the operations, i.e. that
opencoded list operation would just go away, will leave this for
later, in a TODO file.

- Arnaldo
