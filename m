From: Pavel Begunkov <asml.silence@gmail.com>
Date: Fri, 14 Apr 2023 14:56:47 +0000
Subject: Re: [PATCH RFC] io_uring: Pass whole sqe to commands
Message-Id: <e152d8f0-6bf9-f658-f484-f7a18055a664@gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <20230406165705.3161734-1-leitao@debian.org>
In-Reply-To: <20230406165705.3161734-1-leitao@debian.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 4/14/23 14:59, Ming Lei wrote:
[...]
>>> Will this kind of inconsistency cause trouble for driver? Cause READ
>>> TWICE becomes possible with this patch.
>>
>> Right it might happen, and I was keeping that in mind, but it's not
>> specific to this patch. It won't reload core io_uring bits, and all
> 
> It depends if driver reloads core bits or not, anyway the patch exports
> all fields and opens the window.

If a driver tries to reload core bits and even worse modify io_uring
request without proper helpers, it should be rooted out and thrown
into a bin. In any case cmds are expected to exercise cautiousness
while working with SQEs as they may change. I'd even argue that
hiding it as void *cmd makes it much less obvious.

>> fields cmds use already have this problem.
> 
> driver is supposed to load cmds field just once too, right?

Ideally they shouldn't, but it's fine to reload as long as
the cmd can handle it. And it should always be READ_ONCE()
and so.

>> Unless there is a better option, the direction we'll be moving in is
>> adding a preparation step that should read and stash parts of SQE
>> it cares about, which should also make full SQE copy not
>> needed / optional.
> 
> Sounds good.

-- 
Pavel Begunkov
