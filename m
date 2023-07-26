From: Simon Horman <simon.horman@corigine.com>
Date: Wed, 26 Jul 2023 12:56:01 +0000
Subject: Re: [PATCH net] dccp: Allocate enough data in ccid_get_builtin_ccids()
Message-Id: <ZMEX4VOYzz8IvRUQ@corigine.com>
List-Id: <dccp.vger.kernel.org>
References: <35ed2523-49ee-4e2b-b50d-38508f74f93f@moroto.mountain>
In-Reply-To: <35ed2523-49ee-4e2b-b50d-38508f74f93f@moroto.mountain>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On Wed, Jul 26, 2023 at 01:47:02PM +0300, Dan Carpenter wrote:
> This is allocating the ARRAY_SIZE() instead of the number of bytes.  The
> array size is 1 or 2 depending on the .config and it should allocate
> 8 or 16 bytes instead.
> 
> Fixes: ddebc973c56b ("dccp: Lockless integration of CCID congestion-control plugins")
> Signed-off-by: Dan Carpenter <dan.carpenter@linaro.org>

Reviewed-by: Simon Horman <simon.horman@corigine.com>
