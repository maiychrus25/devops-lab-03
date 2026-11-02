# Lab 3 — Tài liệu hệ thống

docs-check: lab3-infrastructure

Trạng thái: hoàn thành và đã dọn tài nguyên — 02/11/2026.

## Phạm vi

Nguồn đề: PhamThuongBlog/VHBTPM_DevOps_2026, commit f4bb72310d326f84bf36b27550dd758f18f54c0a.
Ba file cấu hình là `terraform-aws-lab/main.tf`, `terraform-aws-lab/variables.tf`, `terraform-aws-lab/outputs.tf`.
Thực hành bằng profile `aws-toolkit`, project `145847015645`, vùng `ap-southeast-2`, môi trường `dev`.

## Thiết kế

EC2 t3.micro chạy Amazon Linux 2023 trong default VPC, EBS mã hóa, IMDSv2, CPU credits ở standard.
Security Group mở HTTP 80 và giới hạn SSH 22 theo một địa chỉ IPv4 /32 của người thực hành.
S3 có tên ngẫu nhiên, versioning Enabled và mã hóa AES256; kiểm tra Block Public Access sau khi tạo.
SSH public key do Terraform quản lý; private key lưu ngoài repo trong ~/.ssh và không đưa vào ZIP.

## Vòng đời

Chạy init → validate/test → plan → apply → kiểm chứng → chụp ảnh → destroy.
Chỉ dọn tài nguyên thuộc state của lab. Không sửa tay hoặc đưa state/saved plan vào ZIP.
Provider AWS 5.x chưa đọc được login_session. Dùng `python3 scripts/terraform.py <command>` cho plan/apply/destroy: AWS CLI xuất phiên tạm, script truyền vào environment của tiến trình Terraform, không sửa environment cha hoặc lưu thông tin phiên xuống đĩa. Kiểm chứng bằng unit test và plan thật.

## Kiểm chứng

`make build` khởi tạo và validate cấu hình, kết thúc bằng Build succeeded.
`make test` chạy Terraform mock tests, không tạo tài nguyên thật.
`make lint` kiểm tra terraform fmt và `node scripts/check-docs.js`.
Hai vòng kiểm chứng AWS thật đã PASS; mỗi vòng tám lượt đọc API với tối đa sáu tiến trình đồng thời và 15 assertions. Plan sau apply không có thay đổi. Một unit test cầu nối credentials và ba Terraform mock runs đều PASS.

## Ghi chú sau thực hành

Đề mẫu dùng us-east-1/t2.micro và thông tin IAM access key. Bài này dùng đúng Region của project, t3.micro đủ điều kiện Free Tier, và phiên aws login thay cho khóa dài hạn.
Mẫu thực tế có sáu resource dù đoạn output minh họa ghi bảy; thêm aws_key_pair để Terraform quản lý và dọn cả public key, tổng cộng bảy resource.

## Ghi chú sau hoàn thành

- Apply thật: 7 added, 0 changed, 0 destroyed.
- Instance i-07c08e32d6db58bd7; bucket lab3-dtc235180104-ca1ac8c6; Security Group sg-07672ac62f4e5ff49.
- Đã chụp EC2 Running và S3 Properties trực tiếp trên Console; ảnh log là screenshot hiển thị log lệnh thật, raw logs đi kèm.
- Destroy thật: 7 destroyed. State rỗng; bucket, lab Security Group, key pair và root EBS bị xóa; EC2 terminated.
- Default VPC và default Security Group tồn tại trước lab được giữ nguyên; kiểm chứng trong logs/cleanup.json.
- Bộ ZIP không chứa credentials, private key, state, saved plan, provider binaries hoặc Git internals.
- Chưa kiểm thử SSH vào guest OS; đã xác nhận quy tắc mạng SSH /32 qua API. Chưa upload LMS; bỏ qua bài mở rộng.
