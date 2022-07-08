From: Dan Carpenter <dan.carpenter@oracle.com>
Date: Fri, 08 Jul 2022 10:02:19 +0000
Subject: Re: [linux-next:master] BUILD REGRESSION 088b9c375534d905a4d337c78db3b3bfbb52c4a0
Message-Id: <20220708100219.GJ2338@kadam>
List-Id: <dccp.vger.kernel.org>
References: <62c683a2.g1VSVt6BrQC6ZzOz%lkp@intel.com>
In-Reply-To: <62c683a2.g1VSVt6BrQC6ZzOz%lkp@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On Thu, Jul 07, 2022 at 07:02:58AM -0700, Guenter Roeck wrote:
> and the NULL
> dereferences in the binder driver are at the very least suspicious.

The NULL dereferences in binder are just nonsense Sparse annotations.
They don't affect runtime.

drivers/android/binder.c:1481:19-23: ERROR: from is NULL but dereferenced.
drivers/android/binder.c:2920:29-33: ERROR: target_thread is NULL but dereferenced.
drivers/android/binder.c:353:25-35: ERROR: node -> proc is NULL but dereferenced.
drivers/android/binder.c:4888:16-20: ERROR: t is NULL but dereferenced.

regards,
dan carpenter
