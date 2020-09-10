From: Robin Murphy <robin.murphy@arm.com>
Date: Thu, 10 Sep 2020 14:21:05 +0000
Subject: Re: [trivial PATCH] treewide: Convert switch/case fallthrough; to break;
Message-Id: <9372456a-8dcf-2735-57a4-e126aa5df3a6@arm.com>
List-Id: <dccp.vger.kernel.org>
References: <e6387578c75736d61b2fe70d9783d91329a97eb4.camel@perches.com>
In-Reply-To: <e6387578c75736d61b2fe70d9783d91329a97eb4.camel@perches.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 2020-09-09 21:06, Joe Perches wrote:
> fallthrough to a separate case/default label break; isn't very readable.
> 
> Convert pseudo-keyword fallthrough; statements to a simple break; when
> the next label is case or default and the only statement in the next
> label block is break;
> 
> Found using:
> 
> $ grep-2.5.4 -rP --include=*.[ch] -n "fallthrough;(\s*(case\s+\w+|default)\s*:\s*){1,7}break;" *
> 
> Miscellanea:
> 
> o Move or coalesce a couple label blocks above a default: block.
> 
> Signed-off-by: Joe Perches <joe@perches.com>
> ---
> 
> Compiled allyesconfig x86-64 only.
> A few files for other arches were not compiled.
> 

[...]
> diff --git a/drivers/iommu/arm/arm-smmu-v3/arm-smmu-v3.c b/drivers/iommu/arm/arm-smmu-v3/arm-smmu-v3.c
> index c192544e874b..743db1abec40 100644
> --- a/drivers/iommu/arm/arm-smmu-v3/arm-smmu-v3.c
> +++ b/drivers/iommu/arm/arm-smmu-v3/arm-smmu-v3.c
> @@ -3777,7 +3777,7 @@ static int arm_smmu_device_hw_probe(struct arm_smmu_device *smmu)
>   	switch (FIELD_GET(IDR0_TTF, reg)) {
>   	case IDR0_TTF_AARCH32_64:
>   		smmu->ias = 40;
> -		fallthrough;
> +		break;
>   	case IDR0_TTF_AARCH64:
>   		break;
>   	default:

I have to say I don't really agree with the readability argument for 
this one - a fallthrough is semantically correct here, since the first 
case is a superset of the second. It just happens that anything we would 
do for the common subset is implicitly assumed (there are other 
potential cases we simply haven't added support for at the moment), thus 
the second case is currently empty.

This change actively obfuscates that distinction.

Robin.
