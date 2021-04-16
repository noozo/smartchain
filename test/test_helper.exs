Mox.defmock(
  Blockchain.TargetBlockHashCalculator.MockImpl,
  for: Blockchain.TargetBlockHashCalculator
)

Application.put_env(
  :smartchain,
  :target_block_hash_calculator,
  Blockchain.TargetBlockHashCalculator.MockImpl
)

ExUnit.start()
