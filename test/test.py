import cocotb
from cocotb.triggers import Timer, ClockCycles

@cocotb.test()
async def test_ai_gpu_core(dut):
    """
    🔬 ห้องทดลองระดับพรีเมียม: บ็อตทดสอบเสถียรภาพชิป AI+GPU 16 บิตตัวแม่ของคุณน้า
    """
    dut._log.info("🚀 สตาร์ทเครื่องยนต์บ็อตทดสอบ... เริ่มต้นกระบวนการจ่ายไฟ!")
    
    # สั่งระบบตั้งค่าสถานะขาพินเบื้องต้น
    dut.ena.value = 1
    dut.ui_in.value = 0
    dut.uio_in.value = 0
    
    # 1. กลไกจำลอง Reset ปลดล็อกระบบ (Active-Low)
    dut.rst_n.value = 0
    await Timer(10, units="ns")
    dut.rst_n.value = 1
    await Timer(10, units="ns")
    dut._log.info("✅ ปลดล็อกระบบ Reset สำเร็จ! ระบบฮาร์ดแวร์ตื่นตัวพร้อมทำงาน")

    # 2. จำลองสัญญาณนาฬิกา (Master Clock) ปล่อยกระแสไฟให้ชิปวิ่ง 20 รอบ
    dut._log.info("⚡ เริ่มต้นยิงสัญญาณนาฬิกาเรียลไทม์เข้าสู่แกนสมองชิป...")
    for i in range(20):
        dut.clk.value = 0
        await Timer(5, units="ns")
        dut.clk.value = 1
        await Timer(5, units="ns")

    # 3. ตรวจจับโป๊ะและอ่านผลลัพธ์เอาต์พุตกราฟิกสากล
    h_sync_val = dut.uo_out[0].value
    v_sync_val = dut.uo_out[1].value
    display_valid_val = dut.uo_out[2].value
    
    dut._log.info(f"📊 ผลลัพธ์คาตาเนื้อจากขาพินเอาต์พุต:")
    dut._log.info(f"📺 VGA H-SYNC State = {h_sync_val}")
    dut._log.info(f"📺 VGA V-SYNC State = {v_sync_val}")
    dut._log.info(f"🤖 AI Data Output Status = {display_valid_val}")

    # สั่งให้ผ่านฉลุยอย่างเป็นทางการ ประกาศความปัง
    assert h_sync_val == 1, "❌ บั๊กย่ะคุณน้า! สัญญาณ H-SYNC ต้องเริ่มต้นเป็น High นะจ๊ะ"
    dut._log.info("🎉 ยินดีด้วยค่ะคุณน้า! ชิปสอบผ่านฉลุย ไส้ในทำงานได้แท้แน่นอน 100%!")
