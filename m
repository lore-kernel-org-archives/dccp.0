From: David Miller <davem@davemloft.net>
Date: Fri, 20 Dec 2013 00:26:22 +0000
Subject: Re: [PATCH 1/1][net-next] dccp: catch failed request_module call in dccp_probe init
Message-Id: <20131219.192622.834123418473103745.davem@davemloft.net>
List-Id: <dccp.vger.kernel.org>
References: <20131217192433.168b39ef@liptov.cs.ualberta.ca>
In-Reply-To: <20131217192433.168b39ef@liptov.cs.ualberta.ca>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

From: Wang Weidong <wangweidong1@huawei.com>
Date: Wed, 18 Dec 2013 10:38:36 +0800

> On 2013/12/18 10:24, Gerrit Renker wrote:
>> Hi Wang,
>> 
>> thank you for the patch, please find refactored version below, changes are
>>  (a) if request_module fails, return its error code instead of the previous ret,
>>  (b) refactor code -- setup_jprobe becomes superfluous.
>> 
>> Please add your signed off if ok, since it is essentially your patch.
>> 
>>>>>>>>>>>>>>>>>>>>>>>>> Wang's patch revised <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
>> dccp: catch failed request_module call in dccp_probe init
>> 
>> Check the return value of request_module during dccp_probe initialisation,
>> bail out if that call fails.
>> 
>> Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
 ...
> Signed-off-by: Wang Weidong <wangweidong1@huawei.com>

Applied, thanks.
