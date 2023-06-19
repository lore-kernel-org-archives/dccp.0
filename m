From: David Ahern <dsahern@kernel.org>
Date: Mon, 19 Jun 2023 16:12:55 +0000
Subject: Re: [RFC PATCH v2 1/4] net: wire up support for file_operations->uring_cmd()
Message-Id: <f9a85fcc-33e3-b47b-9c32-1d680edadcf8@kernel.org>
List-Id: <dccp.vger.kernel.org>
References: <20230614110757.3689731-2-leitao@debian.org>
In-Reply-To: <20230614110757.3689731-2-leitao@debian.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 6/19/23 4:20 AM, Breno Leitao wrote:
> On Wed, Jun 14, 2023 at 08:15:10AM -0700, David Ahern wrote:
>> On 6/14/23 5:07 AM, Breno Leitao wrote:
>> io_uring is just another in-kernel user of sockets. There is no reason
>> for io_uring references to be in core net code. It should be using
>> exposed in-kernel APIs and doing any translation of its op codes in
>> io_uring/  code.
> Thanks for the feedback. If we want to keep the network subsystem
> untouched, then I we can do it using an approach similar to the
> following. Is this a better approach moving forward?

yes. It keeps the translation from io_uring commands to networking APIs
in one place and does not need to propagate that translation through the
networking code.
