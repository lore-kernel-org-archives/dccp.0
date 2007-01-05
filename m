From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Fri, 05 Jan 2007 16:36:24 +0000
Subject: Re: [dccp] Re: [PATCH 2/5]: DCCP Recalc on non-loss intervals
Message-Id: <200701051636.24701@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
References: <200612201545.39441.ian.mcdonald@jandi.co.nz>
In-Reply-To: <200612201545.39441.ian.mcdonald@jandi.co.nz>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

|  I would like to change the loss interval linked list to a fixed size 8
|  element array as we're not changing the size of the linked list at any
|  time so it is very inefficient (probably a text book case of when not
|  to use a linked list!!)
Absolutely agree - I was scratching my head about the complexity of the code
and with an array we would have simpler code. 

Witness for instance, dccp_li_hist_interval_new() -- it allocates a fixed list of
length 8, the corresponding (static) array allocation is a one-liner. 

In ccid3_hc_rx_update_li(), there is a complex allocation when the list has not
just been created:

	* first list_add() is called to enqueue at the head of the list
	* and then list_del() is called to remove the oldest loss interval

This is a very complex way of managing a ring buffer. Adding to this that we are
using ~0U to identify empty loss intervals, we would probably much better off
with an array; but this array would have to be managed in the same way as a ring
buffer (but that is not difficult, also textbook stuff)
