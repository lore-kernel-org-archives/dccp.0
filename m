From: David Miller <davem@davemloft.net>
Date: Wed, 14 May 2014 19:34:43 +0000
Subject: Re: [PATCH net-next] dccp: make the request_retries minimum is 1
Message-Id: <20140514.153443.298271641580751103.davem@davemloft.net>
List-Id: <dccp.vger.kernel.org>
References: <53718A36.1040907@huawei.com>
In-Reply-To: <53718A36.1040907@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

From: Wang Weidong <wangweidong1@huawei.com>
Date: Tue, 13 May 2014 10:57:58 +0800

> In Documentation/networking/dccp.txt points that request_retries
> should be greater than 0. So make the extra1 to be &one instead
> of &zero.
> 
> Signed-off-by: Wang Weidong <wangweidong1@huawei.com>

Applied, thank you.
