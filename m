From: David Ahern <dsahern@kernel.org>
Date: Fri, 23 Jun 2023 15:20:25 +0000
Subject: Re: [RFC PATCH v2 1/4] net: wire up support for file_operations->uring_cmd()
Message-Id: <5c6dc00b-9e25-501f-1497-ce7f67694a0e@kernel.org>
List-Id: <dccp.vger.kernel.org>
References: <20230614110757.3689731-2-leitao@debian.org>
In-Reply-To: <20230614110757.3689731-2-leitao@debian.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 6/23/23 3:17 AM, Stefan Metzmacher wrote:
> 
> I'd like to keep it passed to socket layer, so that sockets could
> implement some extra features in an async fashion.
> 
> What about having the function you posted below (and in v3)
> as a default implementation if proto_ops->uring_cmd is NULL?
> 

Nothing about this set needs uring_cmd added to proto ops. It adds uring
commands which are wrappers to networking APIs. Let's keep proper APIs
between subsystems.
