From: Jakub Sitnicki <jakub@cloudflare.com>
Date: Wed, 06 May 2020 12:55:11 +0000
Subject: [PATCH bpf-next 15/17] selftests/bpf: Add verifier tests for bpf_sk_lookup context access
Message-Id: <20200506125514.1020829-16-jakub@cloudflare.com>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Exercise verifier access checks for bpf_sk_lookup context fields.

Signed-off-by: Jakub Sitnicki <jakub@cloudflare.com>
---
 .../selftests/bpf/verifier/ctx_sk_lookup.c    | 696 ++++++++++++++++++
 1 file changed, 696 insertions(+)
 create mode 100644 tools/testing/selftests/bpf/verifier/ctx_sk_lookup.c

diff --git a/tools/testing/selftests/bpf/verifier/ctx_sk_lookup.c b/tools/testing/selftests/bpf/verifier/ctx_sk_lookup.c
new file mode 100644
index 000000000000..167cc3da6502
--- /dev/null
+++ b/tools/testing/selftests/bpf/verifier/ctx_sk_lookup.c
@@ -0,0 +1,696 @@
+{
+	"valid 1,2,4-byte read bpf_sk_lookup src_ip4",
+	.insns = {
+		/* 4-byte read */
+		BPF_LDX_MEM(BPF_W, BPF_REG_0, BPF_REG_1,
+			    offsetof(struct bpf_sk_lookup, src_ip4)),
+		/* 2-byte read */
+		BPF_LDX_MEM(BPF_H, BPF_REG_0, BPF_REG_1,
+			    offsetof(struct bpf_sk_lookup, src_ip4)),
+		BPF_LDX_MEM(BPF_H, BPF_REG_0, BPF_REG_1,
+			    offsetof(struct bpf_sk_lookup, src_ip4) + 2),
+		/* 1-byte read */
+		BPF_LDX_MEM(BPF_B, BPF_REG_0, BPF_REG_1,
+			    offsetof(struct bpf_sk_lookup, src_ip4)),
+		BPF_LDX_MEM(BPF_B, BPF_REG_0, BPF_REG_1,
+			    offsetof(struct bpf_sk_lookup, src_ip4) + 3),
+		BPF_EXIT_INSN(),
+	},
+	.result = ACCEPT,
+	.prog_type = BPF_PROG_TYPE_SK_LOOKUP,
+},
+{
+	"invalid 8-byte read bpf_sk_lookup src_ip4",
+	.insns = {
+		/* 8-byte read */
+		BPF_LDX_MEM(BPF_DW, BPF_REG_0, BPF_REG_1,
+			    offsetof(struct bpf_sk_lookup, src_ip4)),
+		BPF_EXIT_INSN(),
+	},
+	.errstr = "invalid bpf_context access",
+	.result = REJECT,
+	.prog_type = BPF_PROG_TYPE_SK_LOOKUP,
+},
+{
+	"invalid 8-byte write bpf_sk_lookup src_ip4",
+	.insns = {
+		BPF_MOV64_IMM(BPF_REG_0, 0x7f000001U),
+		/* 4-byte write */
+		BPF_STX_MEM(BPF_DW, BPF_REG_1, BPF_REG_0,
+			    offsetof(struct bpf_sk_lookup, src_ip4)),
+		BPF_EXIT_INSN(),
+	},
+	.errstr = "invalid bpf_context access",
+	.result = REJECT,
+	.prog_type = BPF_PROG_TYPE_SK_LOOKUP,
+},
+{
+	"invalid 4-byte write bpf_sk_lookup src_ip4",
+	.insns = {
+		BPF_MOV64_IMM(BPF_REG_0, 0x7f000001U),
+		/* 4-byte write */
+		BPF_STX_MEM(BPF_W, BPF_REG_1, BPF_REG_0,
+			    offsetof(struct bpf_sk_lookup, src_ip4)),
+		BPF_EXIT_INSN(),
+	},
+	.errstr = "invalid bpf_context access",
+	.result = REJECT,
+	.prog_type = BPF_PROG_TYPE_SK_LOOKUP,
+},
+{
+	"invalid 2-byte write bpf_sk_lookup src_ip4",
+	.insns = {
+		BPF_MOV64_IMM(BPF_REG_0, 0x7f000001U),
+		/* 2-byte write */
+		BPF_STX_MEM(BPF_H, BPF_REG_1, BPF_REG_0,
+			    offsetof(struct bpf_sk_lookup, src_ip4)),
+		BPF_EXIT_INSN(),
+	},
+	.errstr = "invalid bpf_context access",
+	.result = REJECT,
+	.prog_type = BPF_PROG_TYPE_SK_LOOKUP,
+},
+{
+	"invalid 1-byte write bpf_sk_lookup src_ip4",
+	.insns = {
+		BPF_MOV64_IMM(BPF_REG_0, 0x7f000001U),
+		/* 1-byte write */
+		BPF_STX_MEM(BPF_B, BPF_REG_1, BPF_REG_0,
+			    offsetof(struct bpf_sk_lookup, src_ip4)),
+		BPF_EXIT_INSN(),
+	},
+	.errstr = "invalid bpf_context access",
+	.result = REJECT,
+	.prog_type = BPF_PROG_TYPE_SK_LOOKUP,
+},
+{
+	"valid 1,2,4-byte read bpf_sk_lookup dst_ip4",
+	.insns = {
+		/* 4-byte read */
+		BPF_LDX_MEM(BPF_W, BPF_REG_0, BPF_REG_1,
+			    offsetof(struct bpf_sk_lookup, dst_ip4)),
+		/* 2-byte read */
+		BPF_LDX_MEM(BPF_H, BPF_REG_0, BPF_REG_1,
+			    offsetof(struct bpf_sk_lookup, dst_ip4)),
+		BPF_LDX_MEM(BPF_H, BPF_REG_0, BPF_REG_1,
+			    offsetof(struct bpf_sk_lookup, dst_ip4) + 2),
+		/* 1-byte read */
+		BPF_LDX_MEM(BPF_B, BPF_REG_0, BPF_REG_1,
+			    offsetof(struct bpf_sk_lookup, dst_ip4)),
+		BPF_LDX_MEM(BPF_B, BPF_REG_0, BPF_REG_1,
+			    offsetof(struct bpf_sk_lookup, dst_ip4) + 3),
+		BPF_MOV64_IMM(BPF_REG_0, 0),
+		BPF_EXIT_INSN(),
+	},
+	.result = ACCEPT,
+	.prog_type = BPF_PROG_TYPE_SK_LOOKUP,
+},
+{
+	"invalid 8-byte read bpf_sk_lookup dst_ip4",
+	.insns = {
+		BPF_LDX_MEM(BPF_DW, BPF_REG_0, BPF_REG_1,
+			    offsetof(struct bpf_sk_lookup, dst_ip4)),
+		BPF_EXIT_INSN(),
+	},
+	.errstr = "invalid bpf_context access",
+	.result = REJECT,
+	.prog_type = BPF_PROG_TYPE_SK_LOOKUP,
+},
+{
+	"invalid 8-byte write bpf_sk_lookup dst_ip4",
+	.insns = {
+		BPF_MOV64_IMM(BPF_REG_0, 0x7f000001U),
+		BPF_STX_MEM(BPF_DW, BPF_REG_1, BPF_REG_0,
+			    offsetof(struct bpf_sk_lookup, dst_ip4)),
+		BPF_EXIT_INSN(),
+	},
+	.errstr = "invalid bpf_context access",
+	.result = REJECT,
+	.prog_type = BPF_PROG_TYPE_SK_LOOKUP,
+},
+{
+	"invalid 4-byte write bpf_sk_lookup dst_ip4",
+	.insns = {
+		BPF_MOV64_IMM(BPF_REG_0, 0x7f000001U),
+		BPF_STX_MEM(BPF_W, BPF_REG_1, BPF_REG_0,
+			    offsetof(struct bpf_sk_lookup, dst_ip4)),
+		BPF_EXIT_INSN(),
+	},
+	.errstr = "invalid bpf_context access",
+	.result = REJECT,
+	.prog_type = BPF_PROG_TYPE_SK_LOOKUP,
+},
+{
+	"invalid 2-byte write bpf_sk_lookup dst_ip4",
+	.insns = {
+		BPF_MOV64_IMM(BPF_REG_0, 0x7f000001U),
+		BPF_STX_MEM(BPF_H, BPF_REG_1, BPF_REG_0,
+			    offsetof(struct bpf_sk_lookup, dst_ip4)),
+		BPF_EXIT_INSN(),
+	},
+	.errstr = "invalid bpf_context access",
+	.result = REJECT,
+	.prog_type = BPF_PROG_TYPE_SK_LOOKUP,
+},
+{
+	"invalid 1-byte write bpf_sk_lookup dst_ip4",
+	.insns = {
+		BPF_MOV64_IMM(BPF_REG_0, 0x7f000001U),
+		BPF_STX_MEM(BPF_B, BPF_REG_1, BPF_REG_0,
+			    offsetof(struct bpf_sk_lookup, dst_ip4)),
+		BPF_EXIT_INSN(),
+	},
+	.errstr = "invalid bpf_context access",
+	.result = REJECT,
+	.prog_type = BPF_PROG_TYPE_SK_LOOKUP,
+},
+{
+	"valid 1,2,4-byte read bpf_sk_lookup src_ip6",
+	.insns = {
+		/* 4-byte read */
+		BPF_LDX_MEM(BPF_W, BPF_REG_0, BPF_REG_1,
+			    offsetof(struct bpf_sk_lookup, src_ip6[0])),
+		BPF_LDX_MEM(BPF_W, BPF_REG_0, BPF_REG_1,
+			    offsetof(struct bpf_sk_lookup, src_ip6[3])),
+		/* 2-byte read */
+		BPF_LDX_MEM(BPF_H, BPF_REG_0, BPF_REG_1,
+			    offsetof(struct bpf_sk_lookup, src_ip6[0])),
+		BPF_LDX_MEM(BPF_H, BPF_REG_0, BPF_REG_1,
+			    offsetof(struct bpf_sk_lookup,
+				     src_ip6[3]) + 2),
+		/* 1-byte read */
+		BPF_LDX_MEM(BPF_B, BPF_REG_0, BPF_REG_1,
+			    offsetof(struct bpf_sk_lookup, src_ip6[0])),
+		BPF_LDX_MEM(BPF_B, BPF_REG_0, BPF_REG_1,
+			    offsetof(struct bpf_sk_lookup,
+				     src_ip6[3]) + 3),
+		BPF_EXIT_INSN(),
+	},
+	.result = ACCEPT,
+	.prog_type = BPF_PROG_TYPE_SK_LOOKUP,
+},
+{
+	"invalid 8-byte read bpf_sk_lookup src_ip6",
+	.insns = {
+		BPF_LDX_MEM(BPF_DW, BPF_REG_0, BPF_REG_1,
+			    offsetof(struct bpf_sk_lookup, src_ip6[0])),
+		BPF_EXIT_INSN(),
+	},
+	.errstr = "invalid bpf_context access",
+	.result = REJECT,
+	.prog_type = BPF_PROG_TYPE_SK_LOOKUP,
+},
+{
+	"invalid 8-byte write bpf_sk_lookup src_ip6",
+	.insns = {
+		BPF_MOV64_IMM(BPF_REG_0, 0x00000001U),
+		BPF_STX_MEM(BPF_DW, BPF_REG_1, BPF_REG_0,
+			    offsetof(struct bpf_sk_lookup, src_ip6[0])),
+		BPF_EXIT_INSN(),
+	},
+	.errstr = "invalid bpf_context access",
+	.result = REJECT,
+	.prog_type = BPF_PROG_TYPE_SK_LOOKUP,
+},
+{
+	"invalid 4-byte write bpf_sk_lookup src_ip6",
+	.insns = {
+		BPF_MOV64_IMM(BPF_REG_0, 0x00000001U),
+		BPF_STX_MEM(BPF_W, BPF_REG_1, BPF_REG_0,
+			    offsetof(struct bpf_sk_lookup, src_ip6[0])),
+		BPF_EXIT_INSN(),
+	},
+	.errstr = "invalid bpf_context access",
+	.result = REJECT,
+	.prog_type = BPF_PROG_TYPE_SK_LOOKUP,
+},
+{
+	"invalid 2-byte write bpf_sk_lookup src_ip6",
+	.insns = {
+		BPF_MOV64_IMM(BPF_REG_0, 0x00000001U),
+		BPF_STX_MEM(BPF_H, BPF_REG_1, BPF_REG_0,
+			    offsetof(struct bpf_sk_lookup, src_ip6[0])),
+		BPF_EXIT_INSN(),
+	},
+	.errstr = "invalid bpf_context access",
+	.result = REJECT,
+	.prog_type = BPF_PROG_TYPE_SK_LOOKUP,
+},
+{
+	"invalid 1-byte write bpf_sk_lookup src_ip6",
+	.insns = {
+		BPF_MOV64_IMM(BPF_REG_0, 0x00000001U),
+		BPF_STX_MEM(BPF_B, BPF_REG_1, BPF_REG_0,
+			    offsetof(struct bpf_sk_lookup, src_ip6[0])),
+		BPF_EXIT_INSN(),
+	},
+	.errstr = "invalid bpf_context access",
+	.result = REJECT,
+	.prog_type = BPF_PROG_TYPE_SK_LOOKUP,
+},
+{
+	"valid 1,2,4-byte read bpf_sk_lookup dst_ip6",
+	.insns = {
+		/* 4-byte read */
+		BPF_LDX_MEM(BPF_W, BPF_REG_0, BPF_REG_1,
+			    offsetof(struct bpf_sk_lookup, dst_ip6[0])),
+		BPF_LDX_MEM(BPF_W, BPF_REG_0, BPF_REG_1,
+			    offsetof(struct bpf_sk_lookup, dst_ip6[3])),
+		/* 2-byte read */
+		BPF_LDX_MEM(BPF_H, BPF_REG_0, BPF_REG_1,
+			    offsetof(struct bpf_sk_lookup, dst_ip6[0])),
+		BPF_LDX_MEM(BPF_H, BPF_REG_0, BPF_REG_1,
+			    offsetof(struct bpf_sk_lookup, dst_ip6[3]) + 2),
+		/* 1-byte read */
+		BPF_LDX_MEM(BPF_B, BPF_REG_0, BPF_REG_1,
+			    offsetof(struct bpf_sk_lookup, dst_ip6[0])),
+		BPF_LDX_MEM(BPF_B, BPF_REG_0, BPF_REG_1,
+			    offsetof(struct bpf_sk_lookup, dst_ip6[3]) + 3),
+		BPF_EXIT_INSN(),
+	},
+	.result = ACCEPT,
+	.prog_type = BPF_PROG_TYPE_SK_LOOKUP,
+},
+{
+	"invalid 8-byte read bpf_sk_lookup dst_ip6",
+	.insns = {
+		BPF_LDX_MEM(BPF_DW, BPF_REG_0, BPF_REG_1,
+			    offsetof(struct bpf_sk_lookup, dst_ip6[0])),
+		BPF_EXIT_INSN(),
+	},
+	.errstr = "invalid bpf_context access",
+	.result = REJECT,
+	.prog_type = BPF_PROG_TYPE_SK_LOOKUP,
+},
+{
+	"invalid 8-byte write bpf_sk_lookup dst_ip6",
+	.insns = {
+		BPF_MOV64_IMM(BPF_REG_0, 0x00000001U),
+		BPF_STX_MEM(BPF_DW, BPF_REG_1, BPF_REG_0,
+			    offsetof(struct bpf_sk_lookup, dst_ip6[0])),
+		BPF_EXIT_INSN(),
+	},
+	.errstr = "invalid bpf_context access",
+	.result = REJECT,
+	.prog_type = BPF_PROG_TYPE_SK_LOOKUP,
+},
+{
+	"invalid 4-byte write bpf_sk_lookup dst_ip6",
+	.insns = {
+		BPF_MOV64_IMM(BPF_REG_0, 0x00000001U),
+		BPF_STX_MEM(BPF_W, BPF_REG_1, BPF_REG_0,
+			    offsetof(struct bpf_sk_lookup, dst_ip6[0])),
+		BPF_EXIT_INSN(),
+	},
+	.errstr = "invalid bpf_context access",
+	.result = REJECT,
+	.prog_type = BPF_PROG_TYPE_SK_LOOKUP,
+},
+{
+	"invalid 2-byte write bpf_sk_lookup dst_ip6",
+	.insns = {
+		BPF_MOV64_IMM(BPF_REG_0, 0x00000001U),
+		BPF_STX_MEM(BPF_H, BPF_REG_1, BPF_REG_0,
+			    offsetof(struct bpf_sk_lookup, dst_ip6[0])),
+		BPF_EXIT_INSN(),
+	},
+	.errstr = "invalid bpf_context access",
+	.result = REJECT,
+	.prog_type = BPF_PROG_TYPE_SK_LOOKUP,
+},
+{
+	"invalid 1-byte write bpf_sk_lookup dst_ip6",
+	.insns = {
+		BPF_MOV64_IMM(BPF_REG_0, 0x00000001U),
+		BPF_STX_MEM(BPF_B, BPF_REG_1, BPF_REG_0,
+			    offsetof(struct bpf_sk_lookup, dst_ip6[0])),
+		BPF_EXIT_INSN(),
+	},
+	.errstr = "invalid bpf_context access",
+	.result = REJECT,
+	.prog_type = BPF_PROG_TYPE_SK_LOOKUP,
+},
+{
+	"valid 4-byte read bpf_sk_lookup src_port",
+	.insns = {
+		BPF_LDX_MEM(BPF_W, BPF_REG_0, BPF_REG_1,
+			    offsetof(struct bpf_sk_lookup, src_port)),
+		BPF_EXIT_INSN(),
+	},
+	.result = ACCEPT,
+	.prog_type = BPF_PROG_TYPE_SK_LOOKUP,
+},
+{
+	"invalid 8-byte read bpf_sk_lookup src_port",
+	.insns = {
+		BPF_LDX_MEM(BPF_DW, BPF_REG_0, BPF_REG_1,
+			    offsetof(struct bpf_sk_lookup, src_port)),
+		BPF_EXIT_INSN(),
+	},
+	.errstr = "invalid bpf_context access",
+	.result = REJECT,
+	.prog_type = BPF_PROG_TYPE_SK_LOOKUP,
+},
+{
+	"invalid 2-byte read bpf_sk_lookup src_port",
+	.insns = {
+		BPF_LDX_MEM(BPF_H, BPF_REG_0, BPF_REG_1,
+			    offsetof(struct bpf_sk_lookup, src_port)),
+		BPF_EXIT_INSN(),
+	},
+	.errstr = "invalid bpf_context access",
+	.result = REJECT,
+	.prog_type = BPF_PROG_TYPE_SK_LOOKUP,
+},
+{
+	"invalid 1-byte read bpf_sk_lookup src_port",
+	.insns = {
+		BPF_LDX_MEM(BPF_B, BPF_REG_0, BPF_REG_1,
+			    offsetof(struct bpf_sk_lookup, src_port)),
+		BPF_EXIT_INSN(),
+	},
+	.errstr = "invalid bpf_context access",
+	.result = REJECT,
+	.prog_type = BPF_PROG_TYPE_SK_LOOKUP,
+},
+{
+	"invalid 8-byte write bpf_sk_lookup src_port",
+	.insns = {
+		BPF_MOV64_IMM(BPF_REG_0, 1234),
+		BPF_STX_MEM(BPF_DW, BPF_REG_1, BPF_REG_0,
+			    offsetof(struct bpf_sk_lookup, src_port)),
+		BPF_EXIT_INSN(),
+	},
+	.errstr = "invalid bpf_context access",
+	.result = REJECT,
+	.prog_type = BPF_PROG_TYPE_SK_LOOKUP,
+},
+{
+	"invalid 4-byte write bpf_sk_lookup src_port",
+	.insns = {
+		BPF_MOV64_IMM(BPF_REG_0, 1234),
+		BPF_STX_MEM(BPF_W, BPF_REG_1, BPF_REG_0,
+			    offsetof(struct bpf_sk_lookup, src_port)),
+		BPF_EXIT_INSN(),
+	},
+	.errstr = "invalid bpf_context access",
+	.result = REJECT,
+	.prog_type = BPF_PROG_TYPE_SK_LOOKUP,
+},
+{
+	"invalid 2-byte write bpf_sk_lookup src_port",
+	.insns = {
+		BPF_MOV64_IMM(BPF_REG_0, 1234),
+		BPF_STX_MEM(BPF_H, BPF_REG_1, BPF_REG_0,
+			    offsetof(struct bpf_sk_lookup, src_port)),
+		BPF_EXIT_INSN(),
+	},
+	.errstr = "invalid bpf_context access",
+	.result = REJECT,
+	.prog_type = BPF_PROG_TYPE_SK_LOOKUP,
+},
+{
+	"invalid 1-byte write bpf_sk_lookup src_port",
+	.insns = {
+		BPF_MOV64_IMM(BPF_REG_0, 1234),
+		BPF_STX_MEM(BPF_B, BPF_REG_1, BPF_REG_0,
+			    offsetof(struct bpf_sk_lookup, src_port)),
+		BPF_EXIT_INSN(),
+	},
+	.errstr = "invalid bpf_context access",
+	.result = REJECT,
+	.prog_type = BPF_PROG_TYPE_SK_LOOKUP,
+},
+{
+	"valid 4-byte read bpf_sk_lookup dst_port",
+	.insns = {
+		BPF_LDX_MEM(BPF_W, BPF_REG_0, BPF_REG_1,
+			    offsetof(struct bpf_sk_lookup, dst_port)),
+		BPF_EXIT_INSN(),
+	},
+	.result = ACCEPT,
+	.prog_type = BPF_PROG_TYPE_SK_LOOKUP,
+},
+{
+	"invalid 8-byte read bpf_sk_lookup dst_port",
+	.insns = {
+		BPF_LDX_MEM(BPF_DW, BPF_REG_0, BPF_REG_1,
+			    offsetof(struct bpf_sk_lookup, dst_port)),
+		BPF_EXIT_INSN(),
+	},
+	.errstr = "invalid bpf_context access",
+	.result = REJECT,
+	.prog_type = BPF_PROG_TYPE_SK_LOOKUP,
+},
+{
+	"invalid 2-byte read bpf_sk_lookup dst_port",
+	.insns = {
+		BPF_LDX_MEM(BPF_H, BPF_REG_0, BPF_REG_1,
+			    offsetof(struct bpf_sk_lookup, dst_port)),
+		BPF_EXIT_INSN(),
+	},
+	.errstr = "invalid bpf_context access",
+	.result = REJECT,
+	.prog_type = BPF_PROG_TYPE_SK_LOOKUP,
+},
+{
+	"invalid 1-byte read bpf_sk_lookup dst_port",
+	.insns = {
+		BPF_LDX_MEM(BPF_B, BPF_REG_0, BPF_REG_1,
+			    offsetof(struct bpf_sk_lookup, dst_port)),
+		BPF_EXIT_INSN(),
+	},
+	.errstr = "invalid bpf_context access",
+	.result = REJECT,
+	.prog_type = BPF_PROG_TYPE_SK_LOOKUP,
+},
+{
+	"invalid 8-byte write bpf_sk_lookup dst_port",
+	.insns = {
+		BPF_MOV64_IMM(BPF_REG_0, 1234),
+		BPF_STX_MEM(BPF_DW, BPF_REG_1, BPF_REG_0,
+			    offsetof(struct bpf_sk_lookup, dst_port)),
+		BPF_EXIT_INSN(),
+	},
+	.errstr = "invalid bpf_context access",
+	.result = REJECT,
+	.prog_type = BPF_PROG_TYPE_SK_LOOKUP,
+},
+{
+	"invalid 4-byte write bpf_sk_lookup dst_port",
+	.insns = {
+		BPF_MOV64_IMM(BPF_REG_0, 1234),
+		BPF_STX_MEM(BPF_W, BPF_REG_1, BPF_REG_0,
+			    offsetof(struct bpf_sk_lookup, dst_port)),
+		BPF_EXIT_INSN(),
+	},
+	.errstr = "invalid bpf_context access",
+	.result = REJECT,
+	.prog_type = BPF_PROG_TYPE_SK_LOOKUP,
+},
+{
+	"invalid 2-byte write bpf_sk_lookup dst_port",
+	.insns = {
+		BPF_MOV64_IMM(BPF_REG_0, 1234),
+		BPF_STX_MEM(BPF_H, BPF_REG_1, BPF_REG_0,
+			    offsetof(struct bpf_sk_lookup, dst_port)),
+		BPF_EXIT_INSN(),
+	},
+	.errstr = "invalid bpf_context access",
+	.result = REJECT,
+	.prog_type = BPF_PROG_TYPE_SK_LOOKUP,
+},
+{
+	"invalid 1-byte write bpf_sk_lookup dst_port",
+	.insns = {
+		BPF_MOV64_IMM(BPF_REG_0, 1234),
+		BPF_STX_MEM(BPF_B, BPF_REG_1, BPF_REG_0,
+			    offsetof(struct bpf_sk_lookup, dst_port)),
+		BPF_EXIT_INSN(),
+	},
+	.errstr = "invalid bpf_context access",
+	.result = REJECT,
+	.prog_type = BPF_PROG_TYPE_SK_LOOKUP,
+},
+{
+	"valid 4-byte read bpf_sk_lookup family",
+	.insns = {
+		BPF_LDX_MEM(BPF_W, BPF_REG_0, BPF_REG_1,
+			    offsetof(struct bpf_sk_lookup, family)),
+		BPF_EXIT_INSN(),
+	},
+	.result = ACCEPT,
+	.prog_type = BPF_PROG_TYPE_SK_LOOKUP,
+},
+{
+	"invalid 8-byte read bpf_sk_lookup family",
+	.insns = {
+		BPF_LDX_MEM(BPF_DW, BPF_REG_0, BPF_REG_1,
+			    offsetof(struct bpf_sk_lookup, family)),
+		BPF_EXIT_INSN(),
+	},
+	.errstr = "invalid bpf_context access",
+	.result = REJECT,
+	.prog_type = BPF_PROG_TYPE_SK_LOOKUP,
+},
+{
+	"invalid 2-byte read bpf_sk_lookup family",
+	.insns = {
+		BPF_LDX_MEM(BPF_H, BPF_REG_0, BPF_REG_1,
+			    offsetof(struct bpf_sk_lookup, family)),
+		BPF_EXIT_INSN(),
+	},
+	.errstr = "invalid bpf_context access",
+	.result = REJECT,
+	.prog_type = BPF_PROG_TYPE_SK_LOOKUP,
+},
+{
+	"invalid 1-byte read bpf_sk_lookup family",
+	.insns = {
+		BPF_LDX_MEM(BPF_B, BPF_REG_0, BPF_REG_1,
+			    offsetof(struct bpf_sk_lookup, family)),
+		BPF_EXIT_INSN(),
+	},
+	.errstr = "invalid bpf_context access",
+	.result = REJECT,
+	.prog_type = BPF_PROG_TYPE_SK_LOOKUP,
+},
+{
+	"invalid 8-byte write bpf_sk_lookup family",
+	.insns = {
+		BPF_MOV64_IMM(BPF_REG_0, 1234),
+		BPF_STX_MEM(BPF_DW, BPF_REG_1, BPF_REG_0,
+			    offsetof(struct bpf_sk_lookup, family)),
+		BPF_EXIT_INSN(),
+	},
+	.errstr = "invalid bpf_context access",
+	.result = REJECT,
+	.prog_type = BPF_PROG_TYPE_SK_LOOKUP,
+},
+{
+	"invalid 4-byte write bpf_sk_lookup family",
+	.insns = {
+		BPF_MOV64_IMM(BPF_REG_0, 1234),
+		BPF_STX_MEM(BPF_W, BPF_REG_1, BPF_REG_0,
+			    offsetof(struct bpf_sk_lookup, family)),
+		BPF_EXIT_INSN(),
+	},
+	.errstr = "invalid bpf_context access",
+	.result = REJECT,
+	.prog_type = BPF_PROG_TYPE_SK_LOOKUP,
+},
+{
+	"invalid 2-byte write bpf_sk_lookup family",
+	.insns = {
+		BPF_MOV64_IMM(BPF_REG_0, 1234),
+		BPF_STX_MEM(BPF_H, BPF_REG_1, BPF_REG_0,
+			    offsetof(struct bpf_sk_lookup, family)),
+		BPF_EXIT_INSN(),
+	},
+	.errstr = "invalid bpf_context access",
+	.result = REJECT,
+	.prog_type = BPF_PROG_TYPE_SK_LOOKUP,
+},
+{
+	"invalid 1-byte write bpf_sk_lookup family",
+	.insns = {
+		BPF_MOV64_IMM(BPF_REG_0, 1234),
+		BPF_STX_MEM(BPF_B, BPF_REG_1, BPF_REG_0,
+			    offsetof(struct bpf_sk_lookup, family)),
+		BPF_EXIT_INSN(),
+	},
+	.errstr = "invalid bpf_context access",
+	.result = REJECT,
+	.prog_type = BPF_PROG_TYPE_SK_LOOKUP,
+},
+{
+	"valid 4-byte read bpf_sk_lookup protocol",
+	.insns = {
+		BPF_LDX_MEM(BPF_W, BPF_REG_0, BPF_REG_1,
+			    offsetof(struct bpf_sk_lookup, protocol)),
+		BPF_EXIT_INSN(),
+	},
+	.result = ACCEPT,
+	.prog_type = BPF_PROG_TYPE_SK_LOOKUP,
+},
+{
+	"invalid 8-byte read bpf_sk_lookup protocol",
+	.insns = {
+		BPF_LDX_MEM(BPF_DW, BPF_REG_0, BPF_REG_1,
+			    offsetof(struct bpf_sk_lookup, protocol)),
+		BPF_EXIT_INSN(),
+	},
+	.errstr = "invalid bpf_context access",
+	.result = REJECT,
+	.prog_type = BPF_PROG_TYPE_SK_LOOKUP,
+},
+{
+	"invalid 2-byte read bpf_sk_lookup protocol",
+	.insns = {
+		BPF_LDX_MEM(BPF_H, BPF_REG_0, BPF_REG_1,
+			    offsetof(struct bpf_sk_lookup, protocol)),
+		BPF_EXIT_INSN(),
+	},
+	.errstr = "invalid bpf_context access",
+	.result = REJECT,
+	.prog_type = BPF_PROG_TYPE_SK_LOOKUP,
+},
+{
+	"invalid 1-byte read bpf_sk_lookup protocol",
+	.insns = {
+		BPF_LDX_MEM(BPF_B, BPF_REG_0, BPF_REG_1,
+			    offsetof(struct bpf_sk_lookup, protocol)),
+		BPF_EXIT_INSN(),
+	},
+	.errstr = "invalid bpf_context access",
+	.result = REJECT,
+	.prog_type = BPF_PROG_TYPE_SK_LOOKUP,
+},
+{
+	"invalid 8-byte write bpf_sk_lookup protocol",
+	.insns = {
+		BPF_MOV64_IMM(BPF_REG_0, 1234),
+		BPF_STX_MEM(BPF_DW, BPF_REG_1, BPF_REG_0,
+			    offsetof(struct bpf_sk_lookup, protocol)),
+		BPF_EXIT_INSN(),
+	},
+	.errstr = "invalid bpf_context access",
+	.result = REJECT,
+	.prog_type = BPF_PROG_TYPE_SK_LOOKUP,
+},
+{
+	"invalid 4-byte write bpf_sk_lookup protocol",
+	.insns = {
+		BPF_MOV64_IMM(BPF_REG_0, 1234),
+		BPF_STX_MEM(BPF_W, BPF_REG_1, BPF_REG_0,
+			    offsetof(struct bpf_sk_lookup, protocol)),
+		BPF_EXIT_INSN(),
+	},
+	.errstr = "invalid bpf_context access",
+	.result = REJECT,
+	.prog_type = BPF_PROG_TYPE_SK_LOOKUP,
+},
+{
+	"invalid 2-byte write bpf_sk_lookup protocol",
+	.insns = {
+		BPF_MOV64_IMM(BPF_REG_0, 1234),
+		BPF_STX_MEM(BPF_H, BPF_REG_1, BPF_REG_0,
+			    offsetof(struct bpf_sk_lookup, protocol)),
+		BPF_EXIT_INSN(),
+	},
+	.errstr = "invalid bpf_context access",
+	.result = REJECT,
+	.prog_type = BPF_PROG_TYPE_SK_LOOKUP,
+},
+{
+	"invalid 1-byte write bpf_sk_lookup protocol",
+	.insns = {
+		BPF_MOV64_IMM(BPF_REG_0, 1234),
+		BPF_STX_MEM(BPF_B, BPF_REG_1, BPF_REG_0,
+			    offsetof(struct bpf_sk_lookup, protocol)),
+		BPF_EXIT_INSN(),
+	},
+	.errstr = "invalid bpf_context access",
+	.result = REJECT,
+	.prog_type = BPF_PROG_TYPE_SK_LOOKUP,
+},
-- 
2.25.3
