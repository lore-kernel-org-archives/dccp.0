From: Pavel Begunkov <asml.silence@gmail.com>
Date: Tue, 11 Apr 2023 12:39:34 +0000
Subject: Re: [PATCH RFC] io_uring: Pass whole sqe to commands
Message-Id: <09f51486-5c27-6fd8-d3c5-0edadef30f81@gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <20230406165705.3161734-1-leitao@debian.org>
In-Reply-To: <20230406165705.3161734-1-leitao@debian.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 4/11/23 13:22, Breno Leitao wrote:
> On Fri, Apr 07, 2023 at 12:51:44PM -0600, Keith Busch wrote:
>>> @@ -63,14 +63,15 @@ EXPORT_SYMBOL_GPL(io_uring_cmd_done);
>>>   int io_uring_cmd_prep_async(struct io_kiocb *req)
>>>   {
>>>   	struct io_uring_cmd *ioucmd = io_kiocb_to_cmd(req, struct io_uring_cmd);
>>> -	size_t cmd_size;
>>> +	size_t size = sizeof(struct io_uring_sqe);
>>>   
>>>   	BUILD_BUG_ON(uring_cmd_pdu_size(0) != 16);
>>>   	BUILD_BUG_ON(uring_cmd_pdu_size(1) != 80);
>>
>> One minor suggestion. The above is the only user of uring_cmd_pdu_size() now,
>> which is kind of a convoluted way to enfoce the offset of the 'cmd' field. It
>> may be more clear to replace these with:
> 
> I agree with you here. Basically it is a bug if the payload (pdu) size is
> is different than 16 for single SQE or != 80 for extended SQE.
> 
> So, basically it is checking for two things:
>     * the cmd offset is 48
>     * the io_uring_sqe struct is 64
> 
> Since this is a uapi, I am not confidence that they will change at all.
> I can replace the code with your suggestion.
> 
>> 	BUILD_BUG_ON(offsetof(struct io_uring_sqe, cmd) = 48);
> 
> It should be "offset(struct io_uring_sqe, cmd) != 48)", right?

Which is already checked, see io_uring_init()

-- 
Pavel Begunkov
