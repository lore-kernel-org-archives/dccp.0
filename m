From: Kleber Souza <kleber.souza@canonical.com>
Date: Thu, 15 Oct 2020 09:23:53 +0000
Subject: Re: [PATCH 2/2] Revert "dccp: don't free ccid2_hc_tx_sock struct in dccp_disconnect()"
Message-Id: <686668d9-8d7a-1ad1-a210-0b6abaa8dc36@canonical.com>
List-Id: <dccp.vger.kernel.org>
References: <20201013171849.236025-3-kleber.souza@canonical.com>
In-Reply-To: <20201013171849.236025-3-kleber.souza@canonical.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 15.10.20 05:42, Jakub Kicinski wrote:
> On Tue, 13 Oct 2020 19:18:49 +0200 Kleber Sacilotto de Souza wrote:
>> From: Thadeu Lima de Souza Cascardo <cascardo@canonical.com>
>>
>> This reverts commit 2677d20677314101293e6da0094ede7b5526d2b1.
>>
>> This fixes an issue that after disconnect, dccps_hc_tx_ccid will still be
>> kept, allowing the socket to be reused as a listener socket, and the cloned
>> socket will free its dccps_hc_tx_ccid, leading to a later use after free,
>> when the listener socket is closed.
>>
>> This addresses CVE-2020-16119.
>>
>> Fixes: 2677d2067731 (dccp: don't free ccid2_hc_tx_sock struct in dccp_disconnect())
>> Reported-by: Hadar Manor
> 
> Does this person has an email address?

We have received this report via a private Launchpad bug and the submitter
didn't provide any public email address, so we have only their name.

> 
>> Signed-off-by: Thadeu Lima de Souza Cascardo <cascardo@canonical.com>
>> Signed-off-by: Kleber Sacilotto de Souza <kleber.souza@canonical.com>
