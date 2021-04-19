Mox.defmock(
  Smartchain.Blockchain.TargetBlockHashCalculator.MockImpl,
  for: Smartchain.Blockchain.TargetBlockHashCalculator
)

Application.put_env(
  :smartchain,
  :target_block_hash_calculator,
  Smartchain.Blockchain.TargetBlockHashCalculator.MockImpl
)

ExUnit.start()
