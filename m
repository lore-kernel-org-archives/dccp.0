From: Dmitry Torokhov <dmitry.torokhov@gmail.com>
Date: Tue, 08 Jan 2013 18:16:46 +0000
Subject: Re: [PATCH 5/5] kfifo: log based kfifo API
Message-Id: <20130108181645.GA7972@core.coreip.homeip.net>
List-Id: <dccp.vger.kernel.org>
References: <1357657073-27352-6-git-send-email-yuanhan.liu@linux.intel.com>
In-Reply-To: <1357657073-27352-6-git-send-email-yuanhan.liu@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Hi Yuanhan,

On Tue, Jan 08, 2013 at 10:57:53PM +0800, Yuanhan Liu wrote:
> The current kfifo API take the kfifo size as input, while it rounds
>  _down_ the size to power of 2 at __kfifo_alloc. This may introduce
> potential issue.
> 
> Take the code at drivers/hid/hid-logitech-dj.c as example:
> 
> 	if (kfifo_alloc(&djrcv_dev->notif_fifo,
>                        DJ_MAX_NUMBER_NOTIFICATIONS * sizeof(struct dj_report),
>                        GFP_KERNEL)) {
> 
> Where, DJ_MAX_NUMBER_NOTIFICATIONS is 8, and sizeo of(struct dj_report)
> is 15.
> 
> Which means it wants to allocate a kfifo buffer which can store 8
> dj_report entries at once. The expected kfifo buffer size would be
> 8 * 15 = 120 then. While, in the end, __kfifo_alloc will turn the
> size to rounddown_power_of_2(120) =  64, and then allocate a buf
> with 64 bytes, which I don't think this is the original author want.
> 
> With the new log API, we can do like following:
> 
> 	int kfifo_size_order = order_base_2(DJ_MAX_NUMBER_NOTIFICATIONS *
> 					    sizeof(struct dj_report));
> 
> 	if (kfifo_alloc(&djrcv_dev->notif_fifo, kfifo_size_order, GFP_KERNEL)) {
> 
> This make sure we will allocate enough kfifo buffer for holding
> DJ_MAX_NUMBER_NOTIFICATIONS dj_report entries.

Why don't you simply change __kfifo_alloc to round the allocation up
instead of down?

Thanks.

-- 
Dmitry
