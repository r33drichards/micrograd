from matplotlib.pyplot import imshow
import torch
import torch.nn as nn
import torch.optim as optim
from torch.utils.data import DataLoader, TensorDataset
from sklearn.datasets import load_digits
import numpy as np
import matplotlib.pyplot as plt
from torch.utils.tensorboard import SummaryWriter
writer = SummaryWriter()

# Set random seed for reproducibility
torch.manual_seed(1337)
np.random.seed(1337)

# Load dataset
digits = load_digits()
X = torch.tensor(digits.data, dtype=torch.float32)
y = torch.tensor(digits.target, dtype=torch.long)
dataset = TensorDataset(X, y)
train_dataset, test_dataset = torch.utils.data.random_split(dataset, [1500, len(dataset) - 1500])
train_loader = DataLoader(train_dataset, batch_size=15, shuffle=True)

# Visualize the first digit
# plt.gray()
# plt.matshow(digits.images[0])
# plt.show()

# Define the model
class MLP(nn.Module):
    def __init__(self):
        super(MLP, self).__init__()
        self.layers = nn.Sequential(
            nn.Linear(64, 64),
            nn.ReLU(),
            nn.Linear(64, 64),
            nn.ReLU(),
            nn.Linear(64, 10),
        )

    def forward(self, x):
        return self.layers(x)

model = MLP()
print(model)

# Loss and optimizer
criterion = nn.CrossEntropyLoss()
optimizer = optim.SGD(model.parameters(), lr=0.1)

# Function to calculate accuracy
def accuracy(outputs, labels):
    _, predicted = torch.max(outputs, dim=1)
    return (predicted == labels).float().mean()

# Training the model
num_epochs = 100
from tqdm import tqdm

for epoch in tqdm(range(num_epochs)):
    for inputs, labels in train_loader:
        optimizer.zero_grad()
        outputs = model(inputs)
        loss = criterion(outputs, labels)
        writer.add_scalar("Loss/train", loss, epoch)
        loss.backward()
        optimizer.step()
    # Print loss every 10 epochs
    if (epoch+1) % 10 == 0:
        acc = accuracy(outputs, labels)
        print(f'Epoch {epoch+1}, Loss: {loss.item():.8f}, Accuracy: {acc * 100:.2f}%')

# Test the model
test_loader = DataLoader(test_dataset, batch_size=64, shuffle=False)
with torch.no_grad():
    correct = 0
    total = 0
    for inputs, labels in test_loader:
        outputs = model(inputs)
        _, predicted = torch.max(outputs.data, 1)
        total += labels.size(0)
        # import pdb; pdb.set_trace()
        correct += (predicted == labels).sum().item()
    print(f'Test Accuracy: {100 * correct / total:.2f}%')


# show 10 images from the test set and their predicted labels
test_loader = DataLoader(test_dataset, batch_size=10, shuffle=False)
with torch.no_grad():
    for inputs, labels in test_loader:
        outputs = model(inputs)
        _, predicted = torch.max(outputs.data, 1)
        for i in range(10):
            plt.subplot(2, 5, i + 1)
            plt.imshow(inputs[i].view(8, 8))
            plt.title(f'Predicted: {predicted[i]}, Target: {labels[i]}')
            plt.axis('off')
        # add total accuracy
        plt.suptitle(f'Test Accuracy: {100 * correct / total:.2f}%')
        plt.show()
        break


def train(num_episodes, f=None, render_mode="human"):
    env = gym.make("LunarLander-v2", render_mode=render_mode)

    agent = Agent(
    env=env,
    )
    if f is not None:
        agent.load(f)
    observation, info = env.reset(seed=42)
    for e in tqdm(range(num_episodes)):
        observation, reward, terminated, *rest = agent.feed_state(observation)
        if terminated:
            # agent.save(f"lunar.{e}.pt")
            observation, info = env.reset()

    agent.save("lunar.pt")

            

    env.close()