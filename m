From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Date: Mon, 01 Oct 2007 03:23:30 +0000
Subject: Re: [PATCH 4/11]: Basic data structure for feature negotiation
Message-Id: <5640c7e00709302023p65416aa5nd059f9b2aab349fd@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 9/28/07, Gerrit Renker <gerrit@erg.abdn.ac.uk> wrote:
> [DCCP]: Basic data structure for feature negotiation
>
> For implementing an improved DCCP feature negotiation, data structures are provided:
>         * a container for the various (SP or NN) values,
>         * symbolic state names to track feature states,
>         * an entry struct which holds all current information together,
>         * elementary functions to fill in and process these structures.
>
> Entry structs are arranged as a FIFO for the following reason: RFC 4340 specifies that
> if multiple options of the same type are present, they are processed in the order of
> their appearance in the packet; which means that this order needs to be preserved in the
> local data structure (the later insertion code also respects this order).
>
> The struct list_head has been chosen for the following reasons: the most frequent operations are
>  * add new entry at tail (when receiving Change or setting socket options);
>  * delete entry (when Confirm has been received);
>  * deep copy of entire list (when cloning from listening socket onto request socket).
>
> I am wondering whether struct list_head is `too fat' for a request socket, but have kept this
> structure since it lead to simpler code. If structure sizes are an issue, I'd be willing to
> convert to singly-linked list later if necessary (but it would need a tail pointer).
>
> The NN value has been set to 64 bit, which is a currently sufficient upper limit (Sequence Window
> feature has 48 bit).
>
> Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Acked-by: Ian McDonald <ian.mcdonald@jandi.co.nz>
-- 
Web1: http://wand.net.nz/~iam4/
Web2: http://www.jandi.co.nz
Blog: http://iansblog.jandi.co.nz
