From: David Miller <davem@davemloft.net>
Date: Sun, 12 May 2019 20:21:47 +0000
Subject: Re: [PATCH] net: dccp : proto: remove Unneeded variable "err"
Message-Id: <20190512.132147.2030976092394243720.davem@davemloft.net>
List-Id: <dccp.vger.kernel.org>
References: <20190512103949.GA2554@hari-Inspiron-1545>
In-Reply-To: <20190512103949.GA2554@hari-Inspiron-1545>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

From: Hariprasad Kelam <hariprasad.kelam@gmail.com>
Date: Sun, 12 May 2019 16:09:49 +0530

> Fix below issue reported by coccicheck
> 
> 
> net/dccp/proto.c:266:5-8: Unneeded variable: "err". Return "0" on line
> 310
> 
> Signed-off-by: Hariprasad Kelam <hariprasad.kelam@gmail.com>

Applied.
