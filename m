From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Date: Sat, 07 Apr 2007 04:25:15 +0000
Subject: Re: [PATCH 8/43]: New RX History Step 2 - Initialisation and cleanup
Message-Id: <5640c7e00704062125r9b18c87n750113d37f0a728c@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <200704051633.46816@strip-the-willow>
In-Reply-To: <200704051633.46816@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 4/6/07, Gerrit Renker <gerrit@erg.abdn.ac.uk> wrote:
> Quoting Ian McDonald:
> |  Given that you are allocating a fixed size amount of memory which is
> |  known at compile time I think that allocating one block per entry is
> |  the wrong approach and you lose half the value of having it in a ring
> |  buffer as you still have to dereference. This uses more memory to
> |  store each of the pointers and there is a good chance that they may
> |  not be contiguous in memory and thus your cache memory gets more
> |  dirty.
> These are good points. Are you suggesting to kmalloc the entire array instead?
> The main point which convinced me to use a slab cache was that the slab cache is
> now global for the entire tfrc_lib module, i.e. when there are e.g. 10 CCID3
> connections, they will all allocate from the same slab.

Yes I was suggesting allocating all in one block as less work in
theory for one allocation.

>
> With regard to your second point, I quote from
> http://www.erg.abdn.ac.uk/users/gerrit/dccp/docs/ccid3_packet_reception/loss_detection/loss_detection_algorithm_notes.txt
> -------------------------------------------------------------------------------
>  1. 'ring' is an array of pointers rather than a contiguous area in
>      memory. The reason is that, when having to swap adjacent entries
>      to sort the history, it is easier to swap pointers than to copy
>      (heavy-weight) history-entry data structs.
> -------------------------------------------------------------------------------
>
> Given that pointer references are needed, is using kmalloc for each of the 4 entries
> a better way than using the slab cache?
>
OK. Didn't read that part. Ignore what I'm saying then!

>
> |  I also share Eddies comment about the size of this.
> Oops - then it means that you are also confusing RX history with LI database.
> The LI database starts at patch #16 (12a) and ends at patch #24. This is the
> receiver history structure, used for loss detection and RTT sampling. The LI
> database has sufficient = 9 entries.

My bad. Yes I am confusing them. I haven't yet read through all the
patches. Again I'm not commenting much unless I think I can add
something but you seem to be doing a good job.
-- 
Web: http://wand.net.nz/~iam4/
Blog: http://iansblog.jandi.co.nz
WAND Network Research Group
