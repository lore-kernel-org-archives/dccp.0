From: Luc Van Oostenryck <luc.vanoostenryck@gmail.com>
Date: Thu, 23 Jul 2020 11:14:47 +0000
Subject: Re: [PATCH 01/26] bpfilter: fix up a sparse annotation
Message-Id: <20200723111447.3xj7cidlsspofsja@ltop.local>
List-Id: <dccp.vger.kernel.org>
References: <20200723060908.50081-2-hch@lst.de>
In-Reply-To: <20200723060908.50081-2-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On Thu, Jul 23, 2020 at 08:08:43AM +0200, Christoph Hellwig wrote:
> The __user doesn't make sense when casting to an integer type, just
> switch to a uintptr_t cast which also removes the need for the __force.

Feel free to add my:

Reviewed-by: Luc Van Oostenryck <luc.vanoostenryck@gmail.com>

-- Luc
