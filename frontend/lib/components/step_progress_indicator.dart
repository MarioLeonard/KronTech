part of 'buttons.dart';

class StepProgressIndicator extends StatelessWidget {
  final int currentStep;
  final int totalSteps;
  final List<String>? stepLabels;

  const StepProgressIndicator({
    super.key,
    required this.currentStep,
    required this.totalSteps,
    this.stepLabels,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: (currentStep + 1) / totalSteps,
            minHeight: 4,
            backgroundColor: Colors.grey.shade200,
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
          ),
        ),
        const SizedBox(height: 12),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(totalSteps, (index) {
            final isCompleted = index < currentStep;
            final isCurrent = index == currentStep;

            return Expanded(
              child: Column(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isCompleted
                          ? Colors.blue
                          : isCurrent
                          ? Colors.blue.shade100
                          : Colors.grey.shade200,
                      border: Border.all(
                        color: isCurrent ? Colors.blue : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    child: Center(
                      child: isCompleted
                          ? const Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 20,
                            )
                          : Text(
                              (index + 1).toString(),
                              style: TextStyle(
                                color: isCurrent ? Colors.blue : Colors.grey,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),
                  if (stepLabels != null && index < stepLabels!.length) ...[
                    const SizedBox(height: 8),
                    Text(
                      stepLabels![index],
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: isCurrent ? Colors.blue : Colors.grey,
                        fontWeight: isCurrent
                            ? FontWeight.w600
                            : FontWeight.w400,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            );
          }),
        ),
      ],
    );
  }
}
